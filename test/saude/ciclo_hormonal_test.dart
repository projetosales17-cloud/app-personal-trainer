import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/saude/ciclo_hormonal.dart';

void main() {
  final inicio = DateTime(2026, 1, 1);

  test('dias 0-4 são fase menstrual', () {
    for (var dia = 0; dia <= 4; dia++) {
      expect(
        calcularFaseCiclo(inicio, referencia: inicio.add(Duration(days: dia))),
        FaseCiclo.menstrual,
        reason: 'dia $dia',
      );
    }
  });

  test('dias 5-12 são fase folicular', () {
    for (var dia = 5; dia <= 12; dia++) {
      expect(
        calcularFaseCiclo(inicio, referencia: inicio.add(Duration(days: dia))),
        FaseCiclo.folicular,
        reason: 'dia $dia',
      );
    }
  });

  test('dias 13-15 são ovulação', () {
    for (var dia = 13; dia <= 15; dia++) {
      expect(
        calcularFaseCiclo(inicio, referencia: inicio.add(Duration(days: dia))),
        FaseCiclo.ovulacao,
        reason: 'dia $dia',
      );
    }
  });

  test('dias 16-27 são fase lútea', () {
    for (var dia = 16; dia <= 27; dia++) {
      expect(
        calcularFaseCiclo(inicio, referencia: inicio.add(Duration(days: dia))),
        FaseCiclo.lutea,
        reason: 'dia $dia',
      );
    }
  });

  test('ciclo se repete a cada 28 dias', () {
    expect(
      calcularFaseCiclo(inicio, referencia: inicio.add(const Duration(days: 28))),
      FaseCiclo.menstrual,
    );
    expect(
      calcularFaseCiclo(inicio, referencia: inicio.add(const Duration(days: 33))),
      FaseCiclo.folicular,
    );
  });

  test('label é legível para cada fase', () {
    expect(FaseCiclo.menstrual.label, 'Menstrual');
    expect(FaseCiclo.folicular.label, 'Folicular');
    expect(FaseCiclo.ovulacao.label, 'Ovulação');
    expect(FaseCiclo.lutea.label, 'Lútea');
  });

  test('duração padrão (28) reproduz as janelas originais', () {
    expect(calcularFaseCiclo(inicio, referencia: inicio.add(const Duration(days: 4))),
        FaseCiclo.menstrual);
    expect(calcularFaseCiclo(inicio, referencia: inicio.add(const Duration(days: 12))),
        FaseCiclo.folicular);
    expect(calcularFaseCiclo(inicio, referencia: inicio.add(const Duration(days: 14))),
        FaseCiclo.ovulacao);
    expect(calcularFaseCiclo(inicio, referencia: inicio.add(const Duration(days: 20))),
        FaseCiclo.lutea);
  });

  test('ciclo curto (24 dias) antecipa a ovulação e encurta a folicular', () {
    // Ovulação estimada ~14 dias antes do fim: dias 9-11.
    expect(
      calcularFaseCiclo(inicio, referencia: inicio.add(const Duration(days: 7)), duracaoCiclo: 24),
      FaseCiclo.folicular,
    );
    expect(
      calcularFaseCiclo(inicio, referencia: inicio.add(const Duration(days: 10)), duracaoCiclo: 24),
      FaseCiclo.ovulacao,
    );
    expect(
      calcularFaseCiclo(inicio, referencia: inicio.add(const Duration(days: 14)), duracaoCiclo: 24),
      FaseCiclo.lutea,
    );
    // Repete a cada 24 dias.
    expect(
      calcularFaseCiclo(inicio, referencia: inicio.add(const Duration(days: 24)), duracaoCiclo: 24),
      FaseCiclo.menstrual,
    );
  });

  test('ciclo longo (35 dias) estende a folicular e mantém a lútea ~14 dias', () {
    // Dia 14 ainda é folicular num ciclo de 35 (era ovulação no de 28).
    expect(
      calcularFaseCiclo(inicio, referencia: inicio.add(const Duration(days: 14)), duracaoCiclo: 35),
      FaseCiclo.folicular,
    );
    // Ovulação estimada ~dias 20-22.
    expect(
      calcularFaseCiclo(inicio, referencia: inicio.add(const Duration(days: 21)), duracaoCiclo: 35),
      FaseCiclo.ovulacao,
    );
    expect(
      calcularFaseCiclo(inicio, referencia: inicio.add(const Duration(days: 28)), duracaoCiclo: 35),
      FaseCiclo.lutea,
    );
  });

  test('duração fora da faixa é ajustada para o limite mais próximo', () {
    // 10 -> 21, 99 -> 40. Só não pode estourar nem lançar.
    expect(
      calcularFaseCiclo(inicio, referencia: inicio, duracaoCiclo: 10),
      FaseCiclo.menstrual,
    );
    expect(
      calcularFaseCiclo(inicio, referencia: inicio.add(const Duration(days: 100)), duracaoCiclo: 99),
      isA<FaseCiclo>(),
    );
  });
}
