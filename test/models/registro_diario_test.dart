import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/models/registro_diario.dart';

void main() {
  test('toJson/fromJson preservam data, refeição e descrição', () {
    final registro = RegistroDiario(
      data: DateTime(2026, 3, 15, 12, 30),
      refeicao: 'Almoço',
      descricao: 'Frango grelhado com arroz e salada',
    );

    final json = registro.toJson();
    final reconstruido = RegistroDiario.fromJson(json);

    expect(reconstruido.data, DateTime(2026, 3, 15, 12, 30));
    expect(reconstruido.refeicao, 'Almoço');
    expect(reconstruido.descricao, 'Frango grelhado com arroz e salada');
  });
}
