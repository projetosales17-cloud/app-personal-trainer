import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/saude/composicao_corporal.dart';
import 'package:app_personal_trainer/saude/sexo.dart';

void main() {
  test('calcularPercentualGordura masculino', () {
    final resultado = calcularPercentualGordura(
      sexo: Sexo.masculino,
      alturaCm: 180,
      pescocoCm: 38,
      cinturaCm: 85,
    );
    expect(resultado, 16.11);
  });

  test('calcularPercentualGordura feminino', () {
    final resultado = calcularPercentualGordura(
      sexo: Sexo.feminino,
      alturaCm: 165,
      pescocoCm: 32,
      cinturaCm: 70,
      quadrilCm: 95,
    );
    expect(resultado, 24.86);
  });

  test('calcularPercentualGordura com medidas inválidas lança ArgumentError', () {
    expect(
      () => calcularPercentualGordura(
        sexo: Sexo.masculino,
        alturaCm: 0,
        pescocoCm: 38,
        cinturaCm: 85,
      ),
      throwsArgumentError,
    );
  });

  test('calcularPercentualGordura com cintura menor que pescoço lança ArgumentError', () {
    expect(
      () => calcularPercentualGordura(
        sexo: Sexo.masculino,
        alturaCm: 180,
        pescocoCm: 40,
        cinturaCm: 35,
      ),
      throwsArgumentError,
    );
  });

  test('calcularPercentualGordura feminino sem quadril lança ArgumentError', () {
    expect(
      () => calcularPercentualGordura(
        sexo: Sexo.feminino,
        alturaCm: 165,
        pescocoCm: 32,
        cinturaCm: 70,
      ),
      throwsArgumentError,
    );
  });
}
