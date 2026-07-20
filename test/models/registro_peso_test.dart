import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/models/registro_peso.dart';

void main() {
  test('toJson/fromJson preservam data e peso', () {
    final registro = RegistroPeso(data: DateTime(2026, 3, 15), pesoKg: 68.5);

    final json = registro.toJson();
    final reconstruido = RegistroPeso.fromJson(json);

    expect(reconstruido.data, DateTime(2026, 3, 15));
    expect(reconstruido.pesoKg, 68.5);
  });
}
