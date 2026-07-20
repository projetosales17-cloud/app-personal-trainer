import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/models/ficha_treino.dart';
import 'package:app_personal_trainer/services/agendador_notificacoes.dart';
import 'package:app_personal_trainer/services/notificacoes_treino_service.dart';
import 'package:app_personal_trainer/services/preferencias_repository.dart';

class _AgendadorFake implements AgendadorNotificacoes {
  bool permissaoConcedida = true;
  List<DateTime>? ultimasDatasAgendadas;
  bool cancelarTodosChamado = false;

  @override
  Future<bool> solicitarPermissao() async => permissaoConcedida;

  @override
  Future<void> agendarLembretesDeTreino(List<DateTime> datas) async {
    ultimasDatasAgendadas = datas;
  }

  @override
  Future<void> cancelarTodos() async {
    cancelarTodosChamado = true;
  }
}

const _dia1 = DiaDeTreino(dia: 1, gruposMusculares: [], exercicios: []);
const _dia2 = DiaDeTreino(dia: 2, gruposMusculares: [], exercicios: []);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('ativar agenda as datas de todos os dias da ficha e salva a preferência', () async {
    final agendador = _AgendadorFake();
    final preferencias = PreferenciasRepository();
    final service = NotificacoesTreinoService(
      agendador: agendador,
      preferenciasRepositorio: preferencias,
    );
    final ficha = FichaTreino(
      dias: const [_dia1, _dia2],
      geradaEm: DateTime(2026, 1, 5),
      validaAte: DateTime(2026, 1, 12),
    );

    final resultado = await service.ativar(ficha);

    expect(resultado, isTrue);
    expect(agendador.ultimasDatasAgendadas, isNotNull);
    expect(agendador.ultimasDatasAgendadas, isNotEmpty);
    expect(await preferencias.notificacoesAtivadas(), isTrue);
  });

  test('ativar retorna false e não agenda nada quando a permissão é negada', () async {
    final agendador = _AgendadorFake()..permissaoConcedida = false;
    final preferencias = PreferenciasRepository();
    await preferencias.definirNotificacoesAtivadas(false);
    final service = NotificacoesTreinoService(
      agendador: agendador,
      preferenciasRepositorio: preferencias,
    );
    final ficha = FichaTreino(
      dias: const [_dia1],
      geradaEm: DateTime(2026, 1, 5),
      validaAte: DateTime(2026, 1, 12),
    );

    final resultado = await service.ativar(ficha);

    expect(resultado, isFalse);
    expect(agendador.ultimasDatasAgendadas, isNull);
    expect(await preferencias.notificacoesAtivadas(), isFalse);
  });

  test('desativar cancela tudo e desliga a preferência', () async {
    final agendador = _AgendadorFake();
    final preferencias = PreferenciasRepository();
    await preferencias.definirNotificacoesAtivadas(true);
    final service = NotificacoesTreinoService(
      agendador: agendador,
      preferenciasRepositorio: preferencias,
    );

    await service.desativar();

    expect(agendador.cancelarTodosChamado, isTrue);
    expect(await preferencias.notificacoesAtivadas(), isFalse);
  });
}
