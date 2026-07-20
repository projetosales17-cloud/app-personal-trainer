import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/models/anamnese.dart';
import 'package:app_personal_trainer/models/exercicio.dart';
import 'package:app_personal_trainer/services/gerador_ficha_treino.dart';

const _anamneseBase = Anamnese(
  idade: 30,
  alturaCm: 170,
  pesoAtualKg: 65,
  objetivoPrincipal: Objetivo.hipertrofia,
  nivelAtividade: NivelAtividade.moderado,
  frequenciaSemanalDias: 3,
);

void main() {
  final gerador = GeradorFichaTreino();

  test('gera um dia de treino para cada dia da frequência semanal', () {
    final ficha = gerador.gerar(_anamneseBase);
    expect(ficha.dias, hasLength(3));
    expect(ficha.dias.map((d) => d.dia), [1, 2, 3]);
  });

  test('a ficha fica válida por 30 dias a partir de agora', () {
    final antes = DateTime.now();
    final ficha = gerador.gerar(_anamneseBase);
    final depois = DateTime.now();

    expect(
      ficha.validaAte.difference(ficha.geradaEm).inDays,
      GeradorFichaTreino.duracaoValidadeDias,
    );
    expect(!ficha.geradaEm.isBefore(antes) || ficha.geradaEm.isAtSameMomentAs(antes), isTrue);
    expect(!ficha.geradaEm.isAfter(depois), isTrue);
  });

  test('cada dia tem pelo menos um exercício', () {
    final ficha = gerador.gerar(_anamneseBase);
    for (final dia in ficha.dias) {
      expect(dia.exercicios, isNotEmpty, reason: 'dia ${dia.dia}');
    }
  });

  test('todos os grupos musculares são cobertos ao longo da semana quando não há lesões', () {
    final ficha = gerador.gerar(_anamneseBase);
    final gruposCobertos = ficha.dias.expand((d) => d.gruposMusculares).toSet();
    expect(gruposCobertos, GrupoMuscular.values.toSet());
  });

  test('exclui o grupo muscular correspondente a uma lesão informada', () {
    const anamneseComLesao = Anamnese(
      idade: 30,
      alturaCm: 170,
      pesoAtualKg: 65,
      objetivoPrincipal: Objetivo.hipertrofia,
      lesoesLimitacoes: ['Joelho'],
      nivelAtividade: NivelAtividade.moderado,
      frequenciaSemanalDias: 3,
    );

    final ficha = gerador.gerar(anamneseComLesao);
    final gruposCobertos = ficha.dias.expand((d) => d.gruposMusculares).toSet();

    expect(gruposCobertos.contains(GrupoMuscular.perna), isFalse);
    for (final dia in ficha.dias) {
      for (final exercicio in dia.exercicios) {
        expect(exercicio.grupoMuscularPrincipal, isNot(GrupoMuscular.perna));
      }
    }
  });

  test('lesão em texto livre (não reconhecida) não filtra nenhum grupo', () {
    const anamneseComLesaoLivre = Anamnese(
      idade: 30,
      alturaCm: 170,
      pesoAtualKg: 65,
      objetivoPrincipal: Objetivo.hipertrofia,
      lesoesLimitacoes: ['Dor no dedo mindinho'],
      nivelAtividade: NivelAtividade.moderado,
      frequenciaSemanalDias: 3,
    );

    final ficha = gerador.gerar(anamneseComLesaoLivre);
    final gruposCobertos = ficha.dias.expand((d) => d.gruposMusculares).toSet();
    expect(gruposCobertos, GrupoMuscular.values.toSet());
  });
}
