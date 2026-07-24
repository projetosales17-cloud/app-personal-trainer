import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/data/biblioteca_produtos.dart';
import 'package:app_personal_trainer/models/produto.dart';
import 'package:app_personal_trainer/services/biblioteca_produtos_repository.dart';

void main() {
  final repositorio = BibliotecaProdutosRepository();

  test('todos retorna a biblioteca inteira', () {
    expect(repositorio.todos().length, bibliotecaProdutos.length);
  });

  test('filtrar sem tag retorna a biblioteca inteira', () {
    expect(repositorio.filtrar().length, bibliotecaProdutos.length);
  });

  test('filtrar por tag retorna só produtos marcados com aquela tag', () {
    final resultado = repositorio.filtrar(tag: TagPerfil.terceiraIdade);
    expect(resultado, isNotEmpty);
    for (final produto in resultado) {
      expect(produto.tags, contains(TagPerfil.terceiraIdade));
    }
  });

  test('todo produto tem id, nome, descrição e faixa de preço preenchidos', () {
    for (final produto in bibliotecaProdutos) {
      expect(produto.id, isNotEmpty);
      expect(produto.nome, isNotEmpty);
      expect(produto.descricao, isNotEmpty);
      expect(produto.faixaPrecoReferencia, isNotEmpty);
    }
  });

  test('ids do catálogo são únicos', () {
    final ids = bibliotecaProdutos.map((p) => p.id).toSet();
    expect(ids.length, bibliotecaProdutos.length);
  });
}
