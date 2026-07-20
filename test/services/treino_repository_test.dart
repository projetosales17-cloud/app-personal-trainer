import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/models/registro_carga.dart';
import 'package:app_personal_trainer/services/treino_repository.dart';

RegistroCarga _registro(String exercicioId, DateTime data, {double pesoKg = 10}) => RegistroCarga(
  exercicioId: exercicioId,
  data: data,
  pesoKg: pesoKg,
  series: 3,
  repeticoes: 12,
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('listarCargas retorna vazio quando nada foi registrado', () async {
    final repositorio = TreinoRepository();
    expect(await repositorio.listarCargas(), isEmpty);
  });

  test('registrarCarga adiciona um registro que pode ser lido de volta', () async {
    final repositorio = TreinoRepository();
    await repositorio.registrarCarga(_registro('flexao-de-braco', DateTime(2026, 1, 1)));

    final registros = await repositorio.listarCargas();
    expect(registros, hasLength(1));
    expect(registros.first.exercicioId, 'flexao-de-braco');
  });

  test('listarCargas retorna os registros ordenados por data crescente', () async {
    final repositorio = TreinoRepository();
    await repositorio.registrarCarga(_registro('flexao-de-braco', DateTime(2026, 1, 10)));
    await repositorio.registrarCarga(_registro('flexao-de-braco', DateTime(2026, 1, 1)));

    final registros = await repositorio.listarCargas();
    expect(registros.map((r) => r.data), [DateTime(2026, 1, 1), DateTime(2026, 1, 10)]);
  });

  test('listarCargasDoExercicio filtra só os registros daquele exercício', () async {
    final repositorio = TreinoRepository();
    await repositorio.registrarCarga(_registro('flexao-de-braco', DateTime(2026, 1, 1)));
    await repositorio.registrarCarga(_registro('agachamento-livre', DateTime(2026, 1, 2)));

    final registros = await repositorio.listarCargasDoExercicio('flexao-de-braco');
    expect(registros, hasLength(1));
    expect(registros.first.exercicioId, 'flexao-de-braco');
  });
}
