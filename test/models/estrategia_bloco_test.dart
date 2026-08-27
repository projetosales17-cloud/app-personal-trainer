import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/models/checkin_progresso.dart';
import 'package:app_personal_trainer/models/estrategia_bloco.dart';
import 'package:app_personal_trainer/models/exercicio.dart';

CheckinProgresso _checkin({
  AderenciaPercebida aderencia = AderenciaPercebida.maisOuMenos,
  DificuldadeTreino dificuldade = DificuldadeTreino.naMedida,
  Recuperacao recuperacao = Recuperacao.umPoucoCansada,
  bool dorNova = false,
  String? regiaoDorNova,
}) => CheckinProgresso(
  data: DateTime(2026, 1, 1),
  blocoConcluido: 1,
  aderencia: aderencia,
  dificuldade: dificuldade,
  recuperacao: recuperacao,
  dorNova: dorNova,
  regiaoDorNova: regiaoDorNova,
  notaDiferenca: false,
  objetivoMudou: false,
);

void main() {
  test('bloco 1 é adaptação: volume reduzido e teto iniciante', () {
    final e = calcularEstrategiaBloco(
      bloco: 1,
      nivelLiberado: NivelExercicio.iniciante,
    );
    expect(e.volumeModificador, lessThan(0));
    expect(e.tetoNivel, NivelExercicio.iniciante);
    expect(e.deload, isFalse);
  });

  test('ciclo acúmulo → intensificação → descarga pelos blocos', () {
    NivelExercicio n = NivelExercicio.intermediario;
    expect(calcularEstrategiaBloco(bloco: 2, nivelLiberado: n).faseNome, contains('acumulación'));
    expect(
      calcularEstrategiaBloco(bloco: 3, nivelLiberado: n).faseNome,
      contains('intensificación'),
    );
    final descarga = calcularEstrategiaBloco(bloco: 4, nivelLiberado: n);
    expect(descarga.faseNome, contains('descarga'));
    expect(descarga.deload, isTrue);
    // volta ao acúmulo
    expect(calcularEstrategiaBloco(bloco: 5, nivelLiberado: n).faseNome, contains('acumulación'));
  });

  test('treino fácil + bem recuperada + boa aderência sobe o volume', () {
    final e = calcularEstrategiaBloco(
      bloco: 3,
      nivelLiberado: NivelExercicio.avancado,
      ultimoCheckin: _checkin(
        aderencia: AderenciaPercebida.quaseTudo,
        dificuldade: DificuldadeTreino.facilDemais,
        recuperacao: Recuperacao.bemRecuperada,
      ),
    );
    final base = calcularEstrategiaBloco(bloco: 3, nivelLiberado: NivelExercicio.avancado);
    expect(e.volumeModificador, greaterThan(base.volumeModificador));
  });

  test('treino difícil demais segura: teto iniciante, deload e volume menor', () {
    final e = calcularEstrategiaBloco(
      bloco: 2,
      nivelLiberado: NivelExercicio.avancado,
      ultimoCheckin: _checkin(dificuldade: DificuldadeTreino.dificilDemais),
    );
    expect(e.tetoNivel, NivelExercicio.iniciante);
    expect(e.deload, isTrue);
  });

  test('dor nova numa região exclui o grupo correspondente', () {
    final e = calcularEstrategiaBloco(
      bloco: 2,
      nivelLiberado: NivelExercicio.intermediario,
      ultimoCheckin: _checkin(dorNova: true, regiaoDorNova: 'Rodilla'),
    );
    expect(e.gruposExcluidosExtra, contains(GrupoMuscular.perna));
    expect(e.mensagem, contains('profesional'));
  });

  test('rotacaoOffset acompanha o número do bloco', () {
    expect(calcularEstrategiaBloco(bloco: 1, nivelLiberado: NivelExercicio.iniciante).rotacaoOffset, 0);
    expect(calcularEstrategiaBloco(bloco: 7, nivelLiberado: NivelExercicio.iniciante).rotacaoOffset, 6);
  });
}
