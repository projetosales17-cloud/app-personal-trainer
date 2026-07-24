import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/services/gamificacao_service.dart';

void main() {
  final service = GamificacaoService();
  final hoje = DateTime(2026, 3, 12); // referência fixa; hoje.weekday é o "dia esperado" dos testes

  test('sem dias da semana escolhidos, streak e meta ficam zerados', () {
    final resultado = service.calcular(
      diasDaSemanaEsperados: null,
      datasCheckin: [hoje],
      referencia: hoje,
    );

    expect(resultado.streakDias, 0);
    expect(resultado.metaSemanalBatida, isFalse);
    expect(resultado.pontosTotais, GamificacaoService.pontosPorSessao);
  });

  test('cada check-in soma pontosPorSessao, independente de dias da semana', () {
    final resultado = service.calcular(
      diasDaSemanaEsperados: null,
      datasCheckin: [hoje, hoje.subtract(const Duration(days: 1))],
      referencia: hoje,
    );

    expect(resultado.pontosTotais, GamificacaoService.pontosPorSessao * 2);
  });

  test('streak conta hoje quando hoje é esperado e já tem check-in', () {
    final resultado = service.calcular(
      diasDaSemanaEsperados: [hoje.weekday],
      datasCheckin: [hoje],
      referencia: hoje,
    );

    expect(resultado.streakDias, 1);
  });

  test('streak não conta hoje quando ainda não há check-in (sem quebrar a sequência)', () {
    final resultado = service.calcular(
      diasDaSemanaEsperados: [hoje.weekday],
      datasCheckin: [hoje.subtract(const Duration(days: 7))],
      referencia: hoje,
    );

    expect(resultado.streakDias, 1);
  });

  test('streak quebra no primeiro dia esperado sem check-in', () {
    final resultado = service.calcular(
      diasDaSemanaEsperados: [hoje.weekday],
      datasCheckin: [
        hoje,
        hoje.subtract(const Duration(days: 7)),
        // hoje - 14 falta (quebra aqui)
        hoje.subtract(const Duration(days: 21)),
      ],
      referencia: hoje,
    );

    expect(resultado.streakDias, 2);
  });

  test('streak soma corretamente vários dias seguidos concluídos', () {
    final resultado = service.calcular(
      diasDaSemanaEsperados: [hoje.weekday],
      datasCheckin: [
        hoje,
        hoje.subtract(const Duration(days: 7)),
        hoje.subtract(const Duration(days: 14)),
        hoje.subtract(const Duration(days: 21)),
      ],
      referencia: hoje,
    );

    expect(resultado.streakDias, 4);
    // Hoje também é o único dia esperado da semana (mesmo weekday) e já
    // tem check-in, então a meta semanal também é batida aqui.
    expect(resultado.metaSemanalBatida, isTrue);
    expect(
      resultado.pontosTotais,
      4 * GamificacaoService.pontosPorSessao +
          4 * GamificacaoService.pontosPorDiaDeStreak +
          GamificacaoService.pontosPorMetaSemanal,
    );
  });

  test('meta semanal batida quando todos os dias esperados da semana (até hoje) têm check-in', () {
    final segunda = hoje.subtract(Duration(days: hoje.weekday - 1));
    final resultado = service.calcular(
      diasDaSemanaEsperados: [1, 3, 5], // segunda, quarta, sexta
      datasCheckin: [
        segunda,
        segunda.add(const Duration(days: 2)),
        if (hoje.weekday >= 5) segunda.add(const Duration(days: 4)),
      ],
      referencia: hoje,
    );

    // hoje é 12/03/2026 (quinta) — segunda e quarta já passaram, sexta ainda não.
    expect(resultado.metaSemanalBatida, isTrue);
  });

  test('meta semanal não batida quando falta check-in de um dia esperado já passado', () {
    final segunda = hoje.subtract(Duration(days: hoje.weekday - 1));
    final resultado = service.calcular(
      diasDaSemanaEsperados: [1, 3, 5],
      datasCheckin: [segunda], // falta quarta, que já passou
      referencia: hoje,
    );

    expect(resultado.metaSemanalBatida, isFalse);
  });
}
