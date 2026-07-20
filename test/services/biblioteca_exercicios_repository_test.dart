import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/data/biblioteca_exercicios.dart';
import 'package:app_personal_trainer/models/exercicio.dart';
import 'package:app_personal_trainer/services/biblioteca_exercicios_repository.dart';

void main() {
  final repositorio = BibliotecaExerciciosRepository();

  test('todos retorna a biblioteca inteira', () {
    expect(repositorio.todos().length, bibliotecaExercicios.length);
  });

  test('filtrar por grupo muscular retorna só exercícios daquele grupo', () {
    final resultado = repositorio.filtrar(grupoMuscular: GrupoMuscular.gluteo);
    expect(resultado, isNotEmpty);
    for (final exercicio in resultado) {
      expect(exercicio.grupoMuscularPrincipal, GrupoMuscular.gluteo);
    }
  });

  test('filtrar por nível retorna só exercícios daquele nível', () {
    final resultado = repositorio.filtrar(nivel: NivelExercicio.avancado);
    expect(resultado, isNotEmpty);
    for (final exercicio in resultado) {
      expect(exercicio.nivel, NivelExercicio.avancado);
    }
  });

  test('filtrar por objetivo retorna só exercícios com aquele objetivo', () {
    final resultado = repositorio.filtrar(objetivo: ObjetivoExercicio.mobilidade);
    expect(resultado, isNotEmpty);
    for (final exercicio in resultado) {
      expect(exercicio.objetivos, contains(ObjetivoExercicio.mobilidade));
    }
  });

  test('porId encontra um exercício existente e retorna null para inexistente', () {
    expect(repositorio.porId('prancha'), isNotNull);
    expect(repositorio.porId('nao-existe'), isNull);
  });
}
