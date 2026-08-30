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

  test('id sobrevive ao round-trip; copyWith preserva o id; antigo cai na data', () {
    final registro = RegistroPeso(data: DateTime(2026, 3, 15), pesoKg: 68.5);
    expect(RegistroPeso.fromJson(registro.toJson()).id, registro.id);
    expect(registro.copyWith(pesoKg: 67).id, registro.id);
    expect(
      RegistroPeso.fromJson({'data': '2026-03-15T00:00:00.000', 'pesoKg': 68.5}).id,
      '2026-03-15T00:00:00.000',
    );
  });
}
