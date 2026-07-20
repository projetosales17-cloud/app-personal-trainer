import 'package:flutter_test/flutter_test.dart';

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

  test('gera 3 dias de variação', () {
    final cardapio = gerador.gerar(_anamneseBase);
    expect(cardapio.dias, hasLength(3));
    expect(cardapio.dias.map((d) => d.dia), [1, 2, 3]);
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
}
