import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/services/progresso_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('listarPesos e ultimoPeso retornam vazio/nulo quando nada foi registrado', () async {
    final repositorio = ProgressoRepository();
    expect(await repositorio.listarPesos(), isEmpty);
    expect(await repositorio.ultimoPeso(), isNull);
  });

  test('registrarPeso adiciona um registro que pode ser lido de volta', () async {
    final repositorio = ProgressoRepository();
    await repositorio.registrarPeso(70, data: DateTime(2026, 1, 1));

    final registros = await repositorio.listarPesos();
    expect(registros, hasLength(1));
    expect(registros.first.pesoKg, 70);
  });

  test('ultimoPeso retorna o registro mais recente, independente da ordem de inserção', () async {
    final repositorio = ProgressoRepository();
    await repositorio.registrarPeso(72, data: DateTime(2026, 1, 10));
    await repositorio.registrarPeso(70, data: DateTime(2026, 1, 1));
    await repositorio.registrarPeso(71, data: DateTime(2026, 1, 5));

    final ultimo = await repositorio.ultimoPeso();
    expect(ultimo!.pesoKg, 72);
    expect(ultimo.data, DateTime(2026, 1, 10));
  });

  test('listarPesos retorna os registros ordenados por data crescente', () async {
    final repositorio = ProgressoRepository();
    await repositorio.registrarPeso(72, data: DateTime(2026, 1, 10));
    await repositorio.registrarPeso(70, data: DateTime(2026, 1, 1));

    final registros = await repositorio.listarPesos();
    expect(registros.map((r) => r.pesoKg), [70, 72]);
  });
}
