import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/data/biblioteca_suplementos.dart';
import 'package:app_personal_trainer/models/suplemento.dart';
import 'package:app_personal_trainer/services/biblioteca_suplementos_repository.dart';

void main() {
  final repositorio = BibliotecaSuplementosRepository();

  test('todos retorna a biblioteca inteira', () {
    expect(repositorio.todos().length, bibliotecaSuplementos.length);
  });

  test('filtrar por tipo retorna só suplementos daquele tipo', () {
    final resultado = repositorio.filtrar(tipo: TipoSuplemento.proteina);
    expect(resultado, isNotEmpty);
    for (final suplemento in resultado) {
      expect(suplemento.tipo, TipoSuplemento.proteina);
    }
  });

  test('sem filtro retorna tudo', () {
    expect(repositorio.filtrar(), bibliotecaSuplementos);
  });
}
