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

  test('id sobrevive ao round-trip e copyWith preserva o id', () {
    final registro = RegistroDiario(
      data: DateTime(2026, 3, 15),
      refeicao: 'Almoço',
      descricao: 'Frango',
    );
    expect(RegistroDiario.fromJson(registro.toJson()).id, registro.id);
    expect(registro.copyWith(descricao: 'Peixe').id, registro.id);
  });

  test('fromJson de registro antigo sem id usa a data como id', () {
    final registro = RegistroDiario.fromJson({
      'data': '2026-03-15T12:30:00.000',
      'refeicao': 'Almoço',
      'descricao': 'Frango',
    });
    expect(registro.id, '2026-03-15T12:30:00.000');
  });
}
