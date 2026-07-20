import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/models/ficha_treino.dart';

void main() {
  test('expirada é falsa quando validaAte está no futuro', () {
    final ficha = FichaTreino(
      dias: const [],
      geradaEm: DateTime.now(),
      validaAte: DateTime.now().add(const Duration(days: 10)),
    );
    expect(ficha.expirada, isFalse);
  });

  test('expirada é verdadeira quando validaAte já passou', () {
    final ficha = FichaTreino(
      dias: const [],
      geradaEm: DateTime.now().subtract(const Duration(days: 40)),
      validaAte: DateTime.now().subtract(const Duration(days: 10)),
    );
    expect(ficha.expirada, isTrue);
  });
}
