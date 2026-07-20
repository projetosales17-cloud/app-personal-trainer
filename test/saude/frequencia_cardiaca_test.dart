import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/saude/frequencia_cardiaca.dart';

void main() {
  test('calcularFcMaxima', () {
    expect(calcularFcMaxima(30), 190);
  });

  test('calcularFcMaxima com idade inválida lança ArgumentError', () {
    expect(() => calcularFcMaxima(0), throwsArgumentError);
  });

  test('calcularZonasTreino', () {
    final zonas = calcularZonasTreino(190);
    expect(zonas['Zona 1 - Recuperação (50-60%)'], (95, 114));
    expect(zonas['Zona 2 - Leve (60-70%)'], (114, 133));
    expect(zonas['Zona 3 - Moderada (70-80%)'], (133, 152));
    expect(zonas['Zona 4 - Intensa (80-90%)'], (152, 171));
    expect(zonas['Zona 5 - Máxima (90-100%)'], (171, 190));
  });

  test('calcularZonasTreino com FC máxima inválida lança ArgumentError', () {
    expect(() => calcularZonasTreino(0), throwsArgumentError);
  });
}
