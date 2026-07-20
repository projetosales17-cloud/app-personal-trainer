import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/services/diario_alimentar_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('listar retorna vazio quando nada foi registrado', () async {
    final repositorio = DiarioAlimentarRepository();
    expect(await repositorio.listar(), isEmpty);
  });

  test('registrar adiciona um registro que pode ser lido de volta', () async {
    final repositorio = DiarioAlimentarRepository();
    await repositorio.registrar('Almoço', 'Frango com arroz', data: DateTime(2026, 1, 1, 12));

    final registros = await repositorio.listar();
    expect(registros, hasLength(1));
    expect(registros.first.refeicao, 'Almoço');
    expect(registros.first.descricao, 'Frango com arroz');
  });

  test('listar retorna os registros ordenados por data crescente', () async {
    final repositorio = DiarioAlimentarRepository();
    await repositorio.registrar('Jantar', 'Sopa', data: DateTime(2026, 1, 10, 20));
    await repositorio.registrar('Café da manhã', 'Ovos', data: DateTime(2026, 1, 1, 8));

    final registros = await repositorio.listar();
    expect(registros.map((r) => r.descricao), ['Ovos', 'Sopa']);
  });
}
