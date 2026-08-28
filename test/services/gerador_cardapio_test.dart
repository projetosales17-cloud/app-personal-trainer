import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/models/alimento.dart';
import 'package:app_personal_trainer/models/anamnese.dart';
import 'package:app_personal_trainer/services/gerador_cardapio.dart';

const _anamneseBase = Anamnese(
  idade: 30,
  alturaCm: 170,
  pesoAtualKg: 65,
  objetivoPrincipal: Objetivo.emagrecimento,
  nivelAtividade: NivelAtividade.moderado,
  frequenciaSemanalDias: 3,
);

void main() {
  final gerador = GeradorCardapio();

  test('gera 7 dias de variação', () {
    final cardapio = gerador.gerar(_anamneseBase);
    expect(cardapio.dias, hasLength(7));
    expect(cardapio.dias.map((d) => d.dia), [1, 2, 3, 4, 5, 6, 7]);
  });

  test('el desayuno nunca trae arroz, frijoles ni carne del almuerzo', () {
    final cardapio = gerador.gerar(_anamneseBase);
    for (final dia in cardapio.dias) {
      final desayuno = dia.refeicoes.firstWhere((r) => r.nome == 'Desayuno');
      for (final alimento in desayuno.alimentos) {
        expect(alimento.refeicoes.contains(Refeicao.cafeDaManha), isTrue,
            reason: '${alimento.nome} no es de desayuno (dia ${dia.dia})');
        expect(alimento.leguminosa, isFalse, reason: alimento.nome);
      }
      final ids = desayuno.alimentos.map((a) => a.id);
      expect(ids, isNot(contains('arroz-integral')));
      expect(ids, isNot(contains('arroz-blanco')));
      expect(ids, isNot(contains('pollo-plancha')));
    }
  });

  test('el desayuno siempre tiene carbohidrato y fruta', () {
    final cardapio = gerador.gerar(_anamneseBase);
    for (final dia in cardapio.dias) {
      final desayuno = dia.refeicoes.firstWhere((r) => r.nome == 'Desayuno');
      final categorias = desayuno.alimentos.map((a) => a.categoria).toSet();
      expect(categorias, contains(CategoriaAlimento.carboidrato), reason: 'dia ${dia.dia}');
      expect(categorias, contains(CategoriaAlimento.fruta), reason: 'dia ${dia.dia}');
    }
  });

  test('el almuerzo siempre incluye una leguminosa (los frijoles del plato)', () {
    final cardapio = gerador.gerar(_anamneseBase);
    for (final dia in cardapio.dias) {
      final almuerzo = dia.refeicoes.firstWhere((r) => r.nome == 'Almuerzo');
      expect(
        almuerzo.alimentos.any((a) => a.leguminosa),
        isTrue,
        reason: 'dia ${dia.dia}: ${almuerzo.alimentos.map((a) => a.nome)}',
      );
    }
  });

  test('ningún alimento se repite dentro del mismo día', () {
    final cardapio = gerador.gerar(_anamneseBase);
    for (final dia in cardapio.dias) {
      final ids = [
        for (final r in dia.refeicoes) ...r.alimentos.map((a) => a.id),
      ];
      expect(ids.toSet(), hasLength(ids.length), reason: 'dia ${dia.dia}: $ids');
    }
  });

  test('o cardápio fica válido por 30 dias a partir de agora', () {
    final antes = DateTime.now();
    final cardapio = gerador.gerar(_anamneseBase);
    final depois = DateTime.now();

    expect(
      cardapio.validaAte.difference(cardapio.geradaEm).inDays,
      GeradorCardapio.duracaoValidadeDias,
    );
    expect(
      !cardapio.geradaEm.isBefore(antes) || cardapio.geradaEm.isAtSameMomentAs(antes),
      isTrue,
    );
    expect(!cardapio.geradaEm.isAfter(depois), isTrue);
  });

  test('sem objetivo de hipertrofia/performance, não inclui Ceia', () {
    final cardapio = gerador.gerar(_anamneseBase);
    for (final dia in cardapio.dias) {
      expect(dia.refeicoes.map((r) => r.nome), isNot(contains('Ceia')));
    }
  });

  test('objetivo hipertrofia inclui uma refeição extra (Ceia)', () {
    const anamneseHipertrofia = Anamnese(
      idade: 30,
      alturaCm: 170,
      pesoAtualKg: 65,
      objetivoPrincipal: Objetivo.hipertrofia,
      nivelAtividade: NivelAtividade.moderado,
      frequenciaSemanalDias: 3,
    );

    final cardapio = gerador.gerar(anamneseHipertrofia);
    for (final dia in cardapio.dias) {
      expect(dia.refeicoes.map((r) => r.nome), contains('Colación nocturna'));
    }
  });

  test('cada refeição tem pelo menos um alimento', () {
    final cardapio = gerador.gerar(_anamneseBase);
    for (final dia in cardapio.dias) {
      for (final refeicao in dia.refeicoes) {
        expect(refeicao.alimentos, isNotEmpty, reason: '${refeicao.nome} do dia ${dia.dia}');
      }
    }
  });

  test('respeita a restrição de lactose da anamnese', () {
    const anamneseComRestricao = Anamnese(
      idade: 30,
      alturaCm: 170,
      pesoAtualKg: 65,
      objetivoPrincipal: Objetivo.emagrecimento,
      restricoesAlimentares: ['Lactosa'],
      nivelAtividade: NivelAtividade.moderado,
      frequenciaSemanalDias: 3,
    );

    final cardapio = gerador.gerar(anamneseComRestricao);
    for (final dia in cardapio.dias) {
      for (final refeicao in dia.refeicoes) {
        for (final alimento in refeicao.alimentos) {
          expect(alimento.contemLactose, isFalse, reason: alimento.nome);
        }
      }
    }
  });

  test('sem informação de ciclo, não há observação de ciclo', () {
    final cardapio = gerador.gerar(_anamneseBase);
    expect(cardapio.observacaoCiclo, isNull);
  });

  test('com data da última menstruação, mostra observação da fase correspondente', () {
    final anamneseMenstrual = Anamnese(
      idade: 30,
      alturaCm: 170,
      pesoAtualKg: 65,
      objetivoPrincipal: Objetivo.emagrecimento,
      nivelAtividade: NivelAtividade.moderado,
      frequenciaSemanalDias: 3,
      dataUltimaMenstruacao: DateTime.now(),
    );

    final cardapio = gerador.gerar(anamneseMenstrual);
    expect(cardapio.observacaoCiclo, contains('Fase menstrual'));
  });

  test('sem condição hormonal nem parto recente, não há observação de foco', () {
    final cardapio = gerador.gerar(_anamneseBase);
    expect(cardapio.observacoesFoco, isEmpty);
  });

  test('merienda nunca traz aceite/sementes soltas como item', () {
    final cardapio = gerador.gerar(_anamneseBase);
    for (final dia in cardapio.dias) {
      final lanche = dia.refeicoes.firstWhere((r) => r.nome == 'Merienda');
      final ids = lanche.alimentos.map((a) => a.id);
      expect(ids, isNot(contains('aceite-oliva')), reason: 'dia ${dia.dia}');
      expect(ids, isNot(contains('linaza-molida')), reason: 'dia ${dia.dia}');
      expect(ids, isNot(contains('chia')), reason: 'dia ${dia.dia}');
      expect(lanche.alimentos, isNotEmpty, reason: 'dia ${dia.dia}');
    }
  });

  test('condição SOP gera dica nutricional específica', () {
    const anamnese = Anamnese(
      idade: 30,
      alturaCm: 170,
      pesoAtualKg: 65,
      objetivoPrincipal: Objetivo.emagrecimento,
      condicaoHormonal: 'SOP (Síndrome de Ovario Poliquístico)',
      nivelAtividade: NivelAtividade.moderado,
      frequenciaSemanalDias: 3,
    );
    final cardapio = gerador.gerar(anamnese);
    expect(cardapio.observacoesFoco, hasLength(1));
    expect(cardapio.observacoesFoco.single, contains('SOP'));
  });

  test('menopausa gera dica de cálcio e proteína', () {
    const anamnese = Anamnese(
      idade: 52,
      alturaCm: 165,
      pesoAtualKg: 68,
      objetivoPrincipal: Objetivo.menopausa,
      condicaoHormonal: 'Menopausia',
      nivelAtividade: NivelAtividade.leve,
      frequenciaSemanalDias: 3,
    );
    final cardapio = gerador.gerar(anamnese);
    expect(cardapio.observacoesFoco.single, contains('calcio'));
  });

  test('parto recente acrescenta dica de pós-parto, junto da condição', () {
    final anamnese = Anamnese(
      idade: 32,
      alturaCm: 168,
      pesoAtualKg: 70,
      objetivoPrincipal: Objetivo.emagrecimento,
      condicaoHormonal: 'SPM / ciclo irregular',
      nivelAtividade: NivelAtividade.leve,
      frequenciaSemanalDias: 3,
      dataParto: DateTime.now().subtract(const Duration(days: 40)),
    );
    final cardapio = gerador.gerar(anamnese);
    expect(cardapio.observacoesFoco, hasLength(2));
    expect(cardapio.observacoesFoco.any((o) => o.contains('SPM')), isTrue);
    expect(cardapio.observacoesFoco.any((o) => o.contains('posparto')), isTrue);
  });

  test('parto antigo (mais de 6 meses) não gera dica de pós-parto', () {
    final anamnese = Anamnese(
      idade: 32,
      alturaCm: 168,
      pesoAtualKg: 70,
      objetivoPrincipal: Objetivo.emagrecimento,
      nivelAtividade: NivelAtividade.leve,
      frequenciaSemanalDias: 3,
      dataParto: DateTime.now().subtract(const Duration(days: 300)),
    );
    final cardapio = gerador.gerar(anamnese);
    expect(cardapio.observacoesFoco, isEmpty);
  });
}
