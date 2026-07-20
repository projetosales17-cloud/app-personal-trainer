import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/data/biblioteca_receitas.dart';
import 'package:app_personal_trainer/models/receita.dart';
import 'package:app_personal_trainer/services/biblioteca_receitas_repository.dart';

void main() {
  final repositorio = BibliotecaReceitasRepository();

  test('todos retorna a biblioteca inteira', () {
    expect(repositorio.todos().length, bibliotecaReceitas.length);
  });

  test('filtrar por tipo de refeição retorna só receitas daquele tipo', () {
    final resultado = repositorio.filtrar(tipoRefeicao: TipoRefeicao.jantar);
    expect(resultado, isNotEmpty);
    for (final receita in resultado) {
      expect(receita.tipoRefeicao, TipoRefeicao.jantar);
    }
  });

  test('filtrar por restrição "Vegana" retorna só receitas veganas', () {
    final resultado = repositorio.filtrar(restricoesUsuaria: const ['Vegana']);
    expect(resultado, isNotEmpty);
    for (final receita in resultado) {
      expect(receita.vegano, isTrue);
    }
    expect(resultado.any((r) => r.id == 'omelete-de-espinafre'), isFalse);
  });

  test('busca encontra pelo título', () {
    final resultado = repositorio.filtrar(busca: 'omelete');
    expect(resultado.any((r) => r.id == 'omelete-de-espinafre'), isTrue);
  });

  test('porId encontra uma receita existente e retorna null para inexistente', () {
    expect(repositorio.porId('omelete-de-espinafre'), isNotNull);
    expect(repositorio.porId('nao-existe'), isNull);
  });
}
