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

  test('café da manhã nunca traz arroz, feijão nem carne de almoço', () {
    final cardapio = gerador.gerar(_anamneseBase);
    for (final dia in cardapio.dias) {
      final cafe = dia.refeicoes.firstWhere((r) => r.nome == 'Café da manhã');
      for (final alimento in cafe.alimentos) {
        expect(
          alimento.refeicoes.contains(Refeicao.cafeDaManha),
          isTrue,
          reason: '${alimento.nome} não é de café da manhã (dia ${dia.dia})',
        );
        expect(alimento.leguminosa, isFalse, reason: alimento.nome);
      }
      final ids = cafe.alimentos.map((a) => a.id);
      expect(ids, isNot(contains('arroz-integral')));
      expect(ids, isNot(contains('arroz-branco')));
      expect(ids, isNot(contains('frango-grelhado')));
    }
  });

  test('café da manhã sempre tem carboidrato e fruta', () {
    final cardapio = gerador.gerar(_anamneseBase);
    for (final dia in cardapio.dias) {
      final cafe = dia.refeicoes.firstWhere((r) => r.nome == 'Café da manhã');
      final categorias = cafe.alimentos.map((a) => a.categoria).toSet();
      expect(categorias, contains(CategoriaAlimento.carboidrato), reason: 'dia ${dia.dia}');
      expect(categorias, contains(CategoriaAlimento.fruta), reason: 'dia ${dia.dia}');
    }
  });

  test('almoço sempre inclui uma leguminosa (o feijão do prato)', () {
    final cardapio = gerador.gerar(_anamneseBase);
    for (final dia in cardapio.dias) {
      final almoco = dia.refeicoes.firstWhere((r) => r.nome == 'Almoço');
      expect(
        almoco.alimentos.any((a) => a.leguminosa),
        isTrue,
        reason: 'dia ${dia.dia}: ${almoco.alimentos.map((a) => a.nome)}',
      );
    }
  });

  test('nenhum alimento se repete dentro do mesmo dia', () {
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
      expect(dia.refeicoes.map((r) => r.nome), contains('Ceia'));
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
      restricoesAlimentares: ['Lactose'],
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

  test('lanche da tarde nunca traz azeite/sementes soltas como item', () {
    final cardapio = gerador.gerar(_anamneseBase);
    for (final dia in cardapio.dias) {
      final lanche = dia.refeicoes.firstWhere((r) => r.nome == 'Lanche da tarde');
      final ids = lanche.alimentos.map((a) => a.id);
      expect(ids, isNot(contains('azeite-de-oliva')), reason: 'dia ${dia.dia}');
      expect(ids, isNot(contains('linhaca-triturada')), reason: 'dia ${dia.dia}');
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
      condicaoHormonal: 'SOP (Síndrome do Ovário Policístico)',
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
      condicaoHormonal: 'Menopausa',
      nivelAtividade: NivelAtividade.leve,
      frequenciaSemanalDias: 3,
    );
    final cardapio = gerador.gerar(anamnese);
    expect(cardapio.observacoesFoco.single, contains('cálcio'));
  });

  test('parto recente acrescenta dica de pós-parto, junto da condição', () {
    final anamnese = Anamnese(
      idade: 32,
      alturaCm: 168,
      pesoAtualKg: 70,
      objetivoPrincipal: Objetivo.emagrecimento,
      condicaoHormonal: 'TPM / ciclo irregular',
      nivelAtividade: NivelAtividade.leve,
      frequenciaSemanalDias: 3,
      dataParto: DateTime.now().subtract(const Duration(days: 40)),
    );
    final cardapio = gerador.gerar(anamnese);
    expect(cardapio.observacoesFoco, hasLength(2));
    expect(cardapio.observacoesFoco.any((o) => o.contains('TPM')), isTrue);
    expect(cardapio.observacoesFoco.any((o) => o.contains('pós-parto')), isTrue);
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
