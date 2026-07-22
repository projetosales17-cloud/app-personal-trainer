import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/tema.dart';

void main() {
  test('tema claro usa Material 3 e brilho claro', () {
    expect(temaClaro.useMaterial3, isTrue);
    expect(temaClaro.colorScheme.brightness, Brightness.light);
  });

  test('tema escuro usa Material 3 e brilho escuro', () {
    expect(temaEscuro.useMaterial3, isTrue);
    expect(temaEscuro.colorScheme.brightness, Brightness.dark);
  });

  test('claro e escuro compartilham a mesma cor primária de origem', () {
    // ColorScheme.fromSeed com a mesma semente gera primary igual entre
    // brightness diferentes só quando a semente já está no tom certo; aqui
    // validamos que pelo menos o matiz (hue) é consistente entre os dois.
    final hueClaro = HSLColor.fromColor(temaClaro.colorScheme.primary).hue;
    final hueEscuro = HSLColor.fromColor(temaEscuro.colorScheme.primary).hue;
    expect((hueClaro - hueEscuro).abs(), lessThan(15));
  });
}
