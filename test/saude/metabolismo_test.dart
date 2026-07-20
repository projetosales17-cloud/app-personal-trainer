import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/models/anamnese.dart';
import 'package:app_personal_trainer/saude/metabolismo.dart';

void main() {
  test('calcularTmb masculino', () {
    expect(calcularTmb(70, 175, 30, Sexo.masculino), 1648.75);
  });

  test('calcularTmb feminino', () {
    expect(calcularTmb(60, 165, 25, Sexo.feminino), 1345.25);
  });

  test('calcularTmb com valores inválidos lança ArgumentError', () {
    expect(() => calcularTmb(0, 175, 30, Sexo.masculino), throwsArgumentError);
  });

  test('calcularGastoCaloricoDiario', () {
    expect(calcularGastoCaloricoDiario(1648.75, NivelAtividade.moderado), 2555.56);
  });
}
