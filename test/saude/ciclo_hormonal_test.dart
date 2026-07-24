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
}
