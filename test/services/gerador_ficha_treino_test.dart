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

  test('local de treino casa só usa exercícios de peso do corpo ou elástico', () {
    const anamneseCasa = Anamnese(
      idade: 30,
      alturaCm: 170,
      pesoAtualKg: 65,
      objetivoPrincipal: Objetivo.hipertrofia,
      nivelAtividade: NivelAtividade.moderado,
      frequenciaSemanalDias: 7,
      localTreino: LocalTreino.casa,
    );

    final ficha = gerador.gerar(anamneseCasa);
    for (final dia in ficha.dias) {
      for (final exercicio in dia.exercicios) {
        expect(
          {Equipamento.nenhum, Equipamento.elastico}.contains(exercicio.equipamento),
          isTrue,
          reason: '${exercicio.nome} usa ${exercicio.equipamento}',
        );
      }
    }
  });

  test('local de treino academia (padrão) não restringe equipamento', () {
    final ficha = gerador.gerar(_anamneseBase);
    final equipamentos = ficha.dias
        .expand((d) => d.exercicios)
        .map((e) => e.equipamento)
        .toSet();
    expect(equipamentos.length, greaterThan(2));
  });

  test('preferência só musculação (padrão) não inclui cardio', () {
    final ficha = gerador.gerar(_anamneseBase);
    for (final dia in ficha.dias) {
      expect(dia.atividadesCardio, isEmpty);
    }
  });

  test('preferência só cardio não inclui exercícios de musculação', () {
    const anamneseSoCardio = Anamnese(
      idade: 30,
      alturaCm: 170,
      pesoAtualKg: 65,
      objetivoPrincipal: Objetivo.emagrecimento,
      nivelAtividade: NivelAtividade.moderado,
      frequenciaSemanalDias: 3,
      preferenciaTreino: PreferenciaTreino.soCardio,
    );

    final ficha = gerador.gerar(anamneseSoCardio);
    for (final dia in ficha.dias) {
      expect(dia.exercicios, isEmpty);
      expect(dia.gruposMusculares, isEmpty);
      expect(dia.atividadesCardio, isNotEmpty);
    }
  });

  test('preferência combinada inclui musculação e cardio no mesmo dia', () {
    const anamneseCombinada = Anamnese(
      idade: 30,
      alturaCm: 170,
      pesoAtualKg: 65,
      objetivoPrincipal: Objetivo.emagrecimento,
      nivelAtividade: NivelAtividade.moderado,
      frequenciaSemanalDias: 3,
      preferenciaTreino: PreferenciaTreino.combinado,
    );

    final ficha = gerador.gerar(anamneseCombinada);
    for (final dia in ficha.dias) {
      expect(dia.exercicios, isNotEmpty, reason: 'dia ${dia.dia}');
      expect(dia.atividadesCardio, isNotEmpty, reason: 'dia ${dia.dia}');
    }
  });

  test('cardio respeita o local de treino (casa não sugere esteira/academia)', () {
    const anamneseCasaCardio = Anamnese(
      idade: 30,
      alturaCm: 170,
      pesoAtualKg: 65,
      objetivoPrincipal: Objetivo.emagrecimento,
      nivelAtividade: NivelAtividade.moderado,
      frequenciaSemanalDias: 3,
      localTreino: LocalTreino.casa,
      preferenciaTreino: PreferenciaTreino.soCardio,
    );

    final ficha = gerador.gerar(anamneseCasaCardio);
    for (final dia in ficha.dias) {
      for (final atividade in dia.atividadesCardio) {
        expect(atividade.local, LocalTreino.casa);
      }
    }
  });
}
