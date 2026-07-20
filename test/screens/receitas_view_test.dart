import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/screens/receitas_view.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Mostra a primeira receita da lista por padrão (sem filtro)', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: ReceitasView())));
    await tester.pump();

    expect(find.text('Omelete de espinafre'), findsOneWidget);
  });

  testWidgets('Filtrar por tipo de refeição mostra só receitas daquele tipo', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: ReceitasView())));
    await tester.pump();

    await tester.drag(find.byKey(const Key('filtro-tipo-refeicao')), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Jantar'));
    await tester.pumpAndSettle();

    expect(find.text('Sopa de legumes com lentilha'), findsOneWidget);
    expect(find.text('Omelete de espinafre'), findsNothing);
  });

  testWidgets('Buscar por palavra-chave filtra a lista', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: ReceitasView())));
    await tester.pump();

    await tester.enterText(find.byKey(const Key('campo-busca-receitas')), 'atum');
    await tester.pump();

    expect(find.text('Salada de atum com folhas verdes'), findsOneWidget);
    expect(find.text('Omelete de espinafre'), findsNothing);
  });

  testWidgets('Tocar em uma receita abre a tela de detalhe com ingredientes', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: ReceitasView())));
    await tester.pump();

    await tester.tap(find.text('Omelete de espinafre'));
    await tester.pumpAndSettle();

    expect(find.text('Ingredientes'), findsOneWidget);
    expect(find.textContaining('2 ovos'), findsOneWidget);
  });
}
