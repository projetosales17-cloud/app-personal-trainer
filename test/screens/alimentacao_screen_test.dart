import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/screens/alimentacao_screen.dart';

const _lista = Key('lista-alimentos');
const _filtros = Key('filtro-categorias');

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Mostra o primeiro alimento da lista por padrão (sem filtro)', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AlimentacaoScreen()));
    await tester.pump();

    expect(find.text('Frango grelhado (peito)'), findsOneWidget);
  });

  testWidgets('É possível rolar até alimentos mais abaixo na lista', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AlimentacaoScreen()));
    await tester.pump();

    await tester.dragUntilVisible(
      find.text('Bebida de soja sem açúcar'),
      find.byKey(_lista),
      const Offset(0, -300),
    );

    expect(find.text('Bebida de soja sem açúcar'), findsOneWidget);
  });

  testWidgets('Filtrar por categoria mostra só os alimentos daquela categoria', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AlimentacaoScreen()));
    await tester.pump();

    await tester.drag(find.byKey(_filtros), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Vegetal'));
    await tester.pumpAndSettle();

    expect(find.text('Brócolis cozido no vapor'), findsOneWidget);
    expect(find.text('Frango grelhado (peito)'), findsNothing);
  });

  testWidgets('Tocar em um alimento abre a tela de detalhe com substituições', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AlimentacaoScreen()));
    await tester.pump();

    await tester.tap(find.text('Frango grelhado (peito)'));
    await tester.pumpAndSettle();

    expect(find.text('Substituições nesta categoria'), findsOneWidget);
    expect(find.text('Tilápia assada'), findsOneWidget);
  });

  testWidgets('Trocar para a aba "Cardápio" mostra o estado sem anamnese', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AlimentacaoScreen()));
    await tester.pump();

    await tester.tap(find.text('Cardápio'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Complete a anamnese'), findsOneWidget);
  });

  testWidgets('Trocar para a aba "Hidratação" mostra o estado sem anamnese', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AlimentacaoScreen()));
    await tester.pump();

    await tester.tap(find.text('Hidratação'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Complete a anamnese'), findsOneWidget);
  });

  testWidgets('Trocar para a aba "Diário" mostra o estado vazio', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AlimentacaoScreen()));
    await tester.pump();

    await tester.tap(find.text('Diário'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nenhum registro no diário ainda'), findsOneWidget);
  });

  testWidgets('Trocar para a aba "Receitas" mostra a lista de receitas', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AlimentacaoScreen()));
    await tester.pump();

    await tester.tap(find.text('Receitas'));
    await tester.pumpAndSettle();

    expect(find.text('Omelete de espinafre'), findsOneWidget);
  });
}
