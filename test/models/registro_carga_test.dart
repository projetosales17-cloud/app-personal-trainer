import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/models/registro_carga.dart';

void main() {
  test('toJson/fromJson preservam todos os campos', () {
    final registro = RegistroCarga(
      exercicioId: 'flexao-de-braco',
      data: DateTime(2026, 3, 15),
      pesoKg: 0,
      series: 3,
      repeticoes: 12,
    );

    final json = registro.toJson();
    final reconstruido = RegistroCarga.fromJson(json);

    expect(reconstruido.exercicioId, 'flexao-de-braco');
    expect(reconstruido.data, DateTime(2026, 3, 15));
    expect(reconstruido.pesoKg, 0);
    expect(reconstruido.series, 3);
    expect(reconstruido.repeticoes, 12);
  });

  test('id sobrevive ao round-trip; copyWith preserva id e exercicioId', () {
    final registro = RegistroCarga(
      exercicioId: 'flexao-de-braco',
      data: DateTime(2026, 3, 15),
      pesoKg: 10,
      series: 3,
      repeticoes: 12,
    );
    expect(RegistroCarga.fromJson(registro.toJson()).id, registro.id);
    final editado = registro.copyWith(pesoKg: 12);
    expect(editado.id, registro.id);
    expect(editado.exercicioId, 'flexao-de-braco');
  });
}
