import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/screens/suplementos_view.dart';

void main() {
  testWidgets('Mostra a lista e o aviso educativo por padrão', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SuplementosView())));
    await tester.pump();

    expect(find.byKey(const Key('lista-suplementos')), findsOneWidget);
    expect(find.text('Proteína de suero (whey protein)'), findsOneWidget);
    expect(find.textContaining('no una recomendación individualizada'), findsOneWidget);
  });

  testWidgets('Filtrar por tipo mostra só suplementos daquele tipo', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SuplementosView())));
    await tester.pump();

    await tester.tap(find.widgetWithText(FilterChip, 'Creatina'));
    await tester.pump();

    expect(find.text('Creatina'), findsWidgets);
    expect(find.text('Proteína de suero (whey protein)'), findsNothing);
  });

  testWidgets('Tocar em um suplemento abre a tela de detalhe com o aviso', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SuplementosView())));
    await tester.pump();

    await tester.tap(find.text('Proteína de suero (whey protein)'));
    await tester.pumpAndSettle();

    expect(find.textContaining('suero de la leche'), findsOneWidget);
    expect(find.text('Rango general de uso'), findsOneWidget);
    expect(find.textContaining('20 a 30 g por porción'), findsOneWidget);
    expect(find.textContaining('Consulta a un(a) nutricionista'), findsOneWidget);
  });
}
