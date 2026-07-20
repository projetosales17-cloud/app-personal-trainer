import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/data/biblioteca_alimentos.dart';
import 'package:app_personal_trainer/models/alimento.dart';
import 'package:app_personal_trainer/services/biblioteca_alimentos_repository.dart';

void main() {
  final repositorio = BibliotecaAlimentosRepository();

  test('todos retorna a biblioteca inteira', () {
    expect(repositorio.todos().length, bibliotecaAlimentos.length);
  });

  test('filtrar por categoria retorna só alimentos daquela categoria', () {
    final resultado = repositorio.filtrar(categoria: CategoriaAlimento.fruta);
    expect(resultado, isNotEmpty);
    for (final alimento in resultado) {
      expect(alimento.categoria, CategoriaAlimento.fruta);
    }
  });

  test('filtrar por restrição "Lactose" exclui alimentos com lactose', () {
    final resultado = repositorio.filtrar(restricoesUsuaria: const ['Lactose']);
    for (final alimento in resultado) {
      expect(alimento.contemLactose, isFalse);
    }
    expect(resultado.any((a) => a.id == 'leite-desnatado'), isFalse);
  });

  test('filtrar por restrição "Vegana" retorna só alimentos veganos', () {
    final resultado = repositorio.filtrar(restricoesUsuaria: const ['Vegana']);
    for (final alimento in resultado) {
      expect(alimento.vegano, isTrue);
    }
    expect(resultado.any((a) => a.id == 'ovo-cozido'), isFalse);
  });

  test('substitutos retorna outros alimentos da mesma categoria, sem incluir o próprio', () {
    final frango = repositorio.porId('frango-grelhado')!;
    final resultado = repositorio.substitutos(frango);

    expect(resultado, isNotEmpty);
    expect(resultado.any((a) => a.id == 'frango-grelhado'), isFalse);
    for (final alimento in resultado) {
      expect(alimento.categoria, CategoriaAlimento.proteina);
    }
  });

  test('porId encontra um alimento existente e retorna null para inexistente', () {
    expect(repositorio.porId('banana'), isNotNull);
    expect(repositorio.porId('nao-existe'), isNull);
  });
}
