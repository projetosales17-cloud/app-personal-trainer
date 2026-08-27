import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/models/checkin_progresso.dart';
import 'package:app_personal_trainer/models/exercicio.dart';
import 'package:app_personal_trainer/services/programa_treino_repository.dart';
import 'package:app_personal_trainer/services/progresso_repository.dart';

CheckinProgresso _checkin({
  int bloco = 1,
  AderenciaPercebida aderencia = AderenciaPercebida.maisOuMenos,
  DificuldadeTreino dificuldade = DificuldadeTreino.naMedida,
  Recuperacao recuperacao = Recuperacao.umPoucoCansada,
  double? peso,
  double? cintura,
}) => CheckinProgresso(
  data: DateTime.now(),
  blocoConcluido: bloco,
  aderencia: aderencia,
  dificuldade: dificuldade,
  recuperacao: recuperacao,
  dorNova: false,
  notaDiferenca: false,
  objetivoMudou: false,
  pesoKg: peso,
  cinturaCm: cintura,
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('iniciarSeNecessario cria o programa uma vez e reusa depois', () async {
    final repo = ProgramaTreinoRepository();
    final a = await repo.iniciarSeNecessario();
    final b = await repo.iniciarSeNecessario();

    expect(a.blocoAtual, 1);
    expect(a.nivelLiberado, NivelExercicio.iniciante);
    expect(b.iniciadoEm, a.iniciadoEm);
  });

  test('registrarCheckin avança o bloco e grava peso/medidas no progresso', () async {
    final progresso = ProgressoRepository();
    final repo = ProgramaTreinoRepository(progressoRepositorio: progresso);
    await repo.iniciarSeNecessario();

    await repo.registrarCheckin(_checkin(peso: 63.5, cintura: 74));

    final programa = await repo.carregar();
    expect(programa!.blocoAtual, 2);
    expect(programa.checkins, hasLength(1));

    expect((await progresso.ultimoPeso())!.pesoKg, 63.5);
    expect((await progresso.listarMedidas()).single.cinturaCm, 74);
  });

  test('treino fácil + bem recuperada + boa aderência sobe o nível liberado', () async {
    final repo = ProgramaTreinoRepository();
    await repo.iniciarSeNecessario();

    await repo.registrarCheckin(_checkin(
      aderencia: AderenciaPercebida.quaseTudo,
      dificuldade: DificuldadeTreino.facilDemais,
      recuperacao: Recuperacao.bemRecuperada,
    ));

    expect((await repo.carregar())!.nivelLiberado, NivelExercicio.intermediario);
  });

  test('treino difícil demais não sobe o nível', () async {
    final repo = ProgramaTreinoRepository();
    await repo.iniciarSeNecessario();

    await repo.registrarCheckin(_checkin(dificuldade: DificuldadeTreino.dificilDemais));

    expect((await repo.carregar())!.nivelLiberado, NivelExercicio.iniciante);
  });

  test('recomecarPrograma apaga o estado do programa', () async {
    final repo = ProgramaTreinoRepository();
    await repo.iniciarSeNecessario();
    await repo.registrarCheckin(_checkin());
    await repo.recomecarPrograma();

    expect(await repo.carregar(), isNull);
    final novo = await repo.iniciarSeNecessario();
    expect(novo.blocoAtual, 1);
  });
}
