import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/data/biblioteca_orientacoes.dart';
import 'package:app_personal_trainer/models/orientacao.dart';
import 'package:app_personal_trainer/services/biblioteca_orientacoes_repository.dart';

void main() {
  final repositorio = BibliotecaOrientacoesRepository();

  test('todos retorna a biblioteca inteira', () {
    expect(repositorio.todos().length, bibliotecaOrientacoes.length);
  });

  test('filtrar por tema retorna só orientações daquele tema', () {
    final resultado = repositorio.filtrar(tema: TemaOrientacao.motivacao);
    expect(resultado, isNotEmpty);
    for (final orientacao in resultado) {
      expect(orientacao.tema, TemaOrientacao.motivacao);
    }
  });

  test('busca encontra por palavra no título', () {
    final resultado = repositorio.filtrar(busca: 'aquecer');
    expect(resultado.any((o) => o.id == 'aquecimento-antes-do-treino'), isTrue);
  });

  test('busca encontra por palavra no corpo do texto', () {
    final resultado = repositorio.filtrar(busca: 'nutricionista');
    expect(resultado, isNotEmpty);
  });

  test('busca é case-insensitive', () {
    final resultado = repositorio.filtrar(busca: 'AQUECER');
    expect(resultado.any((o) => o.id == 'aquecimento-antes-do-treino'), isTrue);
  });

  test('busca sem correspondência retorna vazio', () {
    expect(repositorio.filtrar(busca: 'xyzabc123'), isEmpty);
  });

  test('porId encontra uma orientação existente e retorna null para inexistente', () {
    expect(repositorio.porId('aquecimento-antes-do-treino'), isNotNull);
    expect(repositorio.porId('nao-existe'), isNull);
  });

  test('filtrar por tipo FAQ retorna só perguntas frequentes', () {
    final resultado = repositorio.filtrar(tipo: TipoConteudoOrientacao.faq);
    expect(resultado, isNotEmpty);
    for (final orientacao in resultado) {
      expect(orientacao.tipo, TipoConteudoOrientacao.faq);
    }
  });

  test('artigos existentes continuam com tipo artigo por padrão', () {
    final artigo = repositorio.porId('aquecimento-antes-do-treino');
    expect(artigo!.tipo, TipoConteudoOrientacao.artigo);
  });
}
