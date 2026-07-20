import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/saude/imc.dart';

void main() {
  test('calcularImc', () {
    expect(calcularImc(70, 1.75), 22.86);
  });

  test('calcularImc com peso inválido lança ArgumentError', () {
    expect(() => calcularImc(0, 1.75), throwsArgumentError);
  });

  test('calcularImc com altura inválida lança ArgumentError', () {
    expect(() => calcularImc(70, -1.75), throwsArgumentError);
  });

  test('classificarImc', () {
    expect(classificarImc(17), 'Abaixo do peso');
    expect(classificarImc(22), 'Peso normal');
    expect(classificarImc(27), 'Sobrepeso');
    expect(classificarImc(32), 'Obesidade');
  });

  test('verificarAlertaSaude', () {
    expect(verificarAlertaSaude(15), isNotNull);
    expect(verificarAlertaSaude(41), isNotNull);
    expect(verificarAlertaSaude(40), isNotNull);
    expect(verificarAlertaSaude(22), isNull);
  });
}
