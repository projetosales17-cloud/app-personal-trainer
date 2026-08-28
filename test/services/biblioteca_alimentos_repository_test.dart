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
    final resultado = repositorio.filtrar(restricoesUsuaria: const ['Lactosa']);
    for (final alimento in resultado) {
      expect(alimento.contemLactose, isFalse);
    }
    expect(resultado.any((a) => a.id == 'leche-descremada'), isFalse);
  });

  test('filtrar por restrição "Vegana" retorna só alimentos veganos', () {
    final resultado = repositorio.filtrar(restricoesUsuaria: const ['Vegana']);
    for (final alimento in resultado) {
      expect(alimento.vegano, isTrue);
    }
    expect(resultado.any((a) => a.id == 'huevo-cocido'), isFalse);
  });

  test('substitutos retorna outros alimentos da mesma categoria, sem incluir o próprio', () {
    final pollo = repositorio.porId('pollo-plancha')!;
    final resultado = repositorio.substitutos(pollo);

    expect(resultado, isNotEmpty);
    expect(resultado.any((a) => a.id == 'pollo-plancha'), isFalse);
    for (final alimento in resultado) {
      expect(alimento.categoria, CategoriaAlimento.proteina);
    }
  });

  test('filtrar por refeição retorna só alimentos daquela refeição', () {
    final desayuno = repositorio.filtrar(refeicao: Refeicao.cafeDaManha);
    expect(desayuno, isNotEmpty);
    for (final alimento in desayuno) {
      expect(alimento.refeicoes, contains(Refeicao.cafeDaManha));
    }
    expect(desayuno.any((a) => a.id == 'arroz-blanco'), isFalse);
  });

  test('porId encontra um alimento existente e retorna null para inexistente', () {
    expect(repositorio.porId('platano'), isNotNull);
    expect(repositorio.porId('nao-existe'), isNull);
  });
}
