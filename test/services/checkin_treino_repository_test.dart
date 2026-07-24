import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/services/checkin_treino_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('listar retorna vazio quando nada foi registrado', () async {
    final repositorio = CheckinTreinoRepository();
    expect(await repositorio.listar(), isEmpty);
  });

  test('foiConcluido retorna falso quando não há check-in para a data/dia', () async {
    final repositorio = CheckinTreinoRepository();
    expect(await repositorio.foiConcluido(DateTime(2026, 1, 1), 1), isFalse);
  });

  test('marcarConcluido registra um check-in que pode ser lido de volta', () async {
    final repositorio = CheckinTreinoRepository();
    await repositorio.marcarConcluido(DateTime(2026, 1, 1), 1);

    expect(await repositorio.foiConcluido(DateTime(2026, 1, 1), 1), isTrue);
    final registros = await repositorio.listar();
    expect(registros, hasLength(1));
    expect(registros.first.diaFicha, 1);
  });

  test('marcarConcluido normaliza a hora do dia (mesma data, horas diferentes)', () async {
    final repositorio = CheckinTreinoRepository();
    await repositorio.marcarConcluido(DateTime(2026, 1, 1, 8, 30), 1);

    expect(await repositorio.foiConcluido(DateTime(2026, 1, 1, 22, 0), 1), isTrue);
  });

  test('marcarConcluido chamado duas vezes para a mesma data/dia não duplica', () async {
    final repositorio = CheckinTreinoRepository();
    await repositorio.marcarConcluido(DateTime(2026, 1, 1), 1);
    await repositorio.marcarConcluido(DateTime(2026, 1, 1), 1);

    expect(await repositorio.listar(), hasLength(1));
  });

  test('diaFicha diferente na mesma data gera registros independentes', () async {
    final repositorio = CheckinTreinoRepository();
    await repositorio.marcarConcluido(DateTime(2026, 1, 1), 1);
    await repositorio.marcarConcluido(DateTime(2026, 1, 1), 2);

    expect(await repositorio.listar(), hasLength(2));
    expect(await repositorio.foiConcluido(DateTime(2026, 1, 1), 1), isTrue);
    expect(await repositorio.foiConcluido(DateTime(2026, 1, 1), 2), isTrue);
  });

  test('desmarcarConcluido remove um check-in existente', () async {
    final repositorio = CheckinTreinoRepository();
    await repositorio.marcarConcluido(DateTime(2026, 1, 1), 1);
    await repositorio.desmarcarConcluido(DateTime(2026, 1, 1), 1);

    expect(await repositorio.foiConcluido(DateTime(2026, 1, 1), 1), isFalse);
    expect(await repositorio.listar(), isEmpty);
  });

  test('desmarcarConcluido sem check-in existente não falha', () async {
    final repositorio = CheckinTreinoRepository();
    await repositorio.desmarcarConcluido(DateTime(2026, 1, 1), 1);
    expect(await repositorio.listar(), isEmpty);
  });
}
