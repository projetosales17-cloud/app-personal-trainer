import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/services/motor_aderencia.dart';

void main() {
  final motor = MotorAderencia();
  final hoje = DateTime(2026, 3, 12);
  final diaEsperado = [hoje.weekday];

  test('sem dias da semana escolhidos, não avalia (neutro)', () {
    final resultado = motor.avaliar(
      diasDaSemanaEsperados: null,
      datasCheckin: const [],
      referencia: hoje,
    );

    expect(resultado.emAlerta, isFalse);
    expect(resultado.treinosPuladosConsecutivos, 0);
    expect(resultado.mensagem, isNull);
  });

  test('com dias da semana escolhidos mas lista vazia, não avalia (neutro)', () {
    final resultado = motor.avaliar(
      diasDaSemanaEsperados: const [],
      datasCheckin: const [],
      referencia: hoje,
    );

    expect(resultado.emAlerta, isFalse);
  });

  test('check-in na data esperada mais recente não gera alerta', () {
    final resultado = motor.avaliar(
      diasDaSemanaEsperados: diaEsperado,
      datasCheckin: [hoje.subtract(const Duration(days: 7))],
      referencia: hoje,
    );

    expect(resultado.treinosPuladosConsecutivos, 0);
    expect(resultado.emAlerta, isFalse);
  });

  test('1 treino pulado (mais recente) não atinge o limite de alerta', () {
    final resultado = motor.avaliar(
      diasDaSemanaEsperados: diaEsperado,
      datasCheckin: [hoje.subtract(const Duration(days: 14))],
      referencia: hoje,
    );

    expect(resultado.treinosPuladosConsecutivos, 1);
    expect(resultado.emAlerta, isFalse);
    expect(resultado.mensagem, isNull);
  });

  test('2 treinos seguidos pulados atingem o limite de alerta', () {
    final resultado = motor.avaliar(
      diasDaSemanaEsperados: diaEsperado,
      datasCheckin: [hoje.subtract(const Duration(days: 21))],
      referencia: hoje,
    );

    expect(resultado.treinosPuladosConsecutivos, 2);
    expect(resultado.emAlerta, isTrue);
    expect(resultado.mensagem, isNotNull);
  });

  test('nenhum check-in em nenhuma data esperada gera o máximo da janela', () {
    final resultado = motor.avaliar(
      diasDaSemanaEsperados: diaEsperado,
      datasCheckin: const [],
      referencia: hoje,
    );

    expect(resultado.treinosPuladosConsecutivos, 6);
    expect(resultado.emAlerta, isTrue);
  });

  test('check-in intercalado interrompe a contagem regressiva no primeiro encontrado', () {
    final resultado = motor.avaliar(
      diasDaSemanaEsperados: diaEsperado,
      datasCheckin: [
        hoje.subtract(const Duration(days: 7)),
        hoje.subtract(const Duration(days: 28)),
      ],
      referencia: hoje,
    );

    expect(resultado.treinosPuladosConsecutivos, 0);
    expect(resultado.emAlerta, isFalse);
  });
}
