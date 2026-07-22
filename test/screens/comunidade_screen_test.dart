import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/screens/comunidade_screen.dart';

void main() {
  testWidgets('Mostra as publicações da biblioteca', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ComunidadeScreen()));
    await tester.pump();

    expect(find.byKey(const Key('lista-comunidade')), findsOneWidget);
    expect(find.text('Fernanda S.'), findsOneWidget);
  });

  testWidgets('Filtrar por tipo mostra só publicações daquele tipo', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ComunidadeScreen()));
    await tester.pump();

    // "Fernanda S." é autora de um depoimento; todas as dicas são
    // assinadas por "Equipe" — nomes de autora são únicos por publicação,
    // ao contrário do rótulo de tipo (que também aparece nos chips de
    // filtro, sempre visíveis).
    expect(find.text('Fernanda S.'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'Dica'));
    await tester.pump();

    expect(find.text('Fernanda S.'), findsNothing);
    expect(find.text('Equipe'), findsWidgets);
  });

  testWidgets('Voltar para "Todos" mostra tudo de novo', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ComunidadeScreen()));
    await tester.pump();

    await tester.tap(find.widgetWithText(FilterChip, 'Conquista'));
    await tester.pump();
    expect(find.text('Fernanda S.'), findsNothing);

    await tester.tap(find.widgetWithText(FilterChip, 'Todos'));
    await tester.pump();
    expect(find.text('Fernanda S.'), findsOneWidget);
  });
}
