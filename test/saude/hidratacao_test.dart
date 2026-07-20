import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/models/anamnese.dart';
import 'package:app_personal_trainer/saude/hidratacao.dart';

void main() {
  test('calcularHidratacaoDiaria sedentário', () {
    expect(calcularHidratacaoDiaria(70, NivelAtividade.sedentario), 2450);
  });

  test('calcularHidratacaoDiaria moderado', () {
    expect(calcularHidratacaoDiaria(70, NivelAtividade.moderado), 3000);
  });

  test('calcularHidratacaoDiaria intenso', () {
    expect(calcularHidratacaoDiaria(80, NivelAtividade.intenso), 3550);
  });

  test('calcularHidratacaoDiaria com peso inválido lança ArgumentError', () {
    expect(() => calcularHidratacaoDiaria(0, NivelAtividade.sedentario), throwsArgumentError);
  });
}
