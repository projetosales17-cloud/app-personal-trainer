import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/models/registro_medidas.dart';

void main() {
  test('toJson/fromJson preservam data e medidas informadas', () {
    final registro = RegistroMedidas(
      data: DateTime(2026, 3, 15),
      cinturaCm: 80,
      quadrilCm: 100,
    );

    final json = registro.toJson();
    final reconstruido = RegistroMedidas.fromJson(json);

    expect(reconstruido.data, DateTime(2026, 3, 15));
    expect(reconstruido.cinturaCm, 80);
    expect(reconstruido.quadrilCm, 100);
    expect(reconstruido.bracoCm, isNull);
    expect(reconstruido.coxaCm, isNull);
  });

  test('vazio é verdadeiro quando nenhuma medida foi informada', () {
    final registro = RegistroMedidas(data: DateTime.now());
    expect(registro.vazio, isTrue);
  });

  test('vazio é falso quando pelo menos uma medida foi informada', () {
    final registro = RegistroMedidas(data: DateTime.now(), bracoCm: 30);
    expect(registro.vazio, isFalse);
  });
}
