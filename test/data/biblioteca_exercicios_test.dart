import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/data/biblioteca_exercicios.dart';
import 'package:app_personal_trainer/models/exercicio.dart';

void main() {
  test('todos os ids são únicos', () {
    final ids = bibliotecaExercicios.map((exercicio) => exercicio.id);
    expect(ids.toSet(), hasLength(bibliotecaExercicios.length));
  });

  test('nenhum exercício tem nome ou instruções vazias', () {
    for (final exercicio in bibliotecaExercicios) {
      expect(exercicio.nome.trim(), isNotEmpty, reason: exercicio.id);
      expect(exercicio.instrucoes.trim(), isNotEmpty, reason: exercicio.id);
      expect(exercicio.objetivos, isNotEmpty, reason: exercicio.id);
    }
  });

  test('todo grupo muscular tem pelo menos 5 exercícios', () {
    for (final grupo in GrupoMuscular.values) {
      final quantidade = bibliotecaExercicios
          .where((exercicio) => exercicio.grupoMuscularPrincipal == grupo)
          .length;
      expect(quantidade, greaterThanOrEqualTo(5), reason: grupo.label);
    }
  });
}
