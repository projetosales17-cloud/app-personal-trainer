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

    expect(find.text('Pechuga de pollo a la plancha'), findsOneWidget);
  });

  testWidgets('É possível rolar até alimentos mais abaixo na lista', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AlimentacaoScreen()));
    await tester.pump();

    await tester.dragUntilVisible(
      find.text('Bebida de soya sin azúcar'),
      find.byKey(_lista),
      const Offset(0, -300),
    );

    expect(find.text('Bebida de soya sin azúcar'), findsOneWidget);
  });

  testWidgets('Filtrar por categoria mostra só os alimentos daquela categoria', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AlimentacaoScreen()));
    await tester.pump();

    await tester.drag(find.byKey(_filtros), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Vegetal'));
    await tester.pumpAndSettle();

    expect(find.text('Brócoli cocido al vapor'), findsOneWidget);
    expect(find.text('Pechuga de pollo a la plancha'), findsNothing);
  });

  testWidgets('Tocar em um alimento abre a tela de detalhe com substituições', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AlimentacaoScreen()));
    await tester.pump();

    await tester.tap(find.text('Pechuga de pollo a la plancha'));
    await tester.pumpAndSettle();

    expect(find.text('Sustituciones en esta categoría'), findsOneWidget);
    expect(find.text('Tilapia al horno'), findsOneWidget);
  });

  testWidgets('Trocar para a aba "Cardápio" mostra o estado sem anamnese', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AlimentacaoScreen()));
    await tester.pump();

    await tester.tap(find.text('Menú'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Completa la anamnesis'), findsOneWidget);
  });

  testWidgets('Trocar para a aba "Hidratação" mostra a calculadora', (tester) async {
    await tester.pumpWidget(MaterialApp(home: AlimentacaoScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hidratación'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('campo-peso-hidratacion')), findsOneWidget);
  });

  testWidgets('Trocar para a aba "Diário" mostra o estado vazio', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AlimentacaoScreen()));
    await tester.pump();

    await tester.tap(find.text('Diario'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Todavía no hay registros en el diario'), findsOneWidget);
  });

  testWidgets('Trocar para a aba "Receitas" mostra a lista de receitas', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AlimentacaoScreen()));
    await tester.pump();

    await tester.tap(find.text('Recetas'));
    await tester.pumpAndSettle();

    expect(find.text('Omelette de espinaca'), findsOneWidget);
  });

  testWidgets('Trocar para a aba "Suplementos" mostra a lista e o aviso educativo', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AlimentacaoScreen()));
    await tester.pump();

    await tester.ensureVisible(find.text('Suplementos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suplementos'));
    await tester.pumpAndSettle();

    expect(find.text('Proteína de suero (whey protein)'), findsOneWidget);
    expect(find.textContaining('no una recomendación individualizada'), findsOneWidget);
  });
}
