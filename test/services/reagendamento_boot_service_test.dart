import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/models/anamnese.dart';
import 'package:app_personal_trainer/services/agendador_notificacoes.dart';
import 'package:app_personal_trainer/services/anamnese_repository.dart';
import 'package:app_personal_trainer/services/notificacoes_treino_service.dart';
import 'package:app_personal_trainer/services/preferencias_repository.dart';
import 'package:app_personal_trainer/services/reagendamento_boot_service.dart';

class _AgendadorFake implements AgendadorNotificacoes {
  List<DateTime>? ultimasDatasAgendadas;

  @override
  Future<bool> solicitarPermissao() async => true;

  @override
  Future<void> agendarLembretesDeTreino(List<DateTime> datas) async {
    ultimasDatasAgendadas = datas;
  }

  @override
  Future<void> cancelarTodos() async {}
}

const _anamnese = Anamnese(
  idade: 30,
  alturaCm: 170,
  pesoAtualKg: 65,
  objetivoPrincipal: Objetivo.hipertrofia,
  nivelAtividade: NivelAtividade.moderado,
  frequenciaSemanalDias: 3,
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('sem anamnese salva, não agenda nada', () async {
    final agendador = _AgendadorFake();
    final servico = ReagendamentoBootService(
      notificacoesService: NotificacoesTreinoService(agendador: agendador),
    );

    await servico.executar();

    expect(agendador.ultimasDatasAgendadas, isNull);
  });

  test('com anamnese salva e notificações ativadas (padrão), reagenda', () async {
    final agendador = _AgendadorFake();
    final anamneseRepositorio = AnamneseRepository();
    await anamneseRepositorio.salvar(_anamnese);
    final servico = ReagendamentoBootService(
      anamneseRepositorio: anamneseRepositorio,
      notificacoesService: NotificacoesTreinoService(agendador: agendador),
    );

    await servico.executar();

    expect(agendador.ultimasDatasAgendadas, isNotNull);
    expect(agendador.ultimasDatasAgendadas, isNotEmpty);
  });

  test('com notificações desativadas explicitamente, não agenda', () async {
    final agendador = _AgendadorFake();
    final anamneseRepositorio = AnamneseRepository();
    await anamneseRepositorio.salvar(_anamnese);
    final preferencias = PreferenciasRepository();
    await preferencias.definirNotificacoesAtivadas(false);
    final servico = ReagendamentoBootService(
      anamneseRepositorio: anamneseRepositorio,
      preferenciasRepositorio: preferencias,
      notificacoesService: NotificacoesTreinoService(
        agendador: agendador,
        preferenciasRepositorio: preferencias,
      ),
    );

    await servico.executar();

    expect(agendador.ultimasDatasAgendadas, isNull);
  });

  test('repassa os dias da semana escolhidos manualmente', () async {
    final agendador = _AgendadorFake();
    final anamneseRepositorio = AnamneseRepository();
    await anamneseRepositorio.salvar(_anamnese);
    final preferencias = PreferenciasRepository();
    // _anamnese tem frequenciaSemanalDias: 3 — precisa da mesma quantidade
    // de dias escolhidos, senão FichaTreino.datasPara ignora e cai na
    // distribuição automática.
    await preferencias.definirDiasDaSemanaEscolhidos([2, 4, 6]);
    final servico = ReagendamentoBootService(
      anamneseRepositorio: anamneseRepositorio,
      preferenciasRepositorio: preferencias,
      notificacoesService: NotificacoesTreinoService(
        agendador: agendador,
        preferenciasRepositorio: preferencias,
      ),
    );

    await servico.executar();

    final diasAgendados = agendador.ultimasDatasAgendadas!.map((d) => d.weekday).toSet();
    expect(diasAgendados, {2, 4, 6});
  });
}
