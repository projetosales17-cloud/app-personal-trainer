import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/screens/treino_screen.dart';

const _lista = Key('lista-exercicios');

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Mostra o primeiro exercício da lista por padrão (sem filtro)', (tester) async {
    await tester.pumpWidget(MaterialApp(home: TreinoScreen()));

    expect(find.text('Flexión de brazos'), findsOneWidget);
  });

  testWidgets('É possível rolar até exercícios mais abaixo na lista', (tester) async {
    await tester.pumpWidget(MaterialApp(home: TreinoScreen()));

    await tester.dragUntilVisible(
      find.text('Plancha'),
      find.byKey(_lista),
      const Offset(0, -300),
    );

    expect(find.text('Plancha'), findsOneWidget);
  });

  testWidgets('Filtrar por grupo muscular mostra só os exercícios daquele grupo', (tester) async {
    await tester.pumpWidget(MaterialApp(home: TreinoScreen()));

    // Rola a lista horizontal de filtros o suficiente para o chip "Glúteo"
    // ficar bem dentro da área visível (não só na borda do cache extent).
    await tester.drag(find.byKey(const Key('filtro-grupos')), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Glúteo'));
    await tester.pumpAndSettle();

    expect(find.text('Elevación de cadera'), findsOneWidget);
    expect(find.text('Flexión de brazos'), findsNothing);
  });

  testWidgets('Tocar em um exercício abre a tela de detalhe', (tester) async {
    await tester.pumpWidget(MaterialApp(home: TreinoScreen()));

    await tester.tap(find.text('Flexión de brazos'));
    await tester.pumpAndSettle();

    expect(find.text('Cómo hacerlo'), findsOneWidget);
    expect(find.textContaining('ancho de los hombros'), findsOneWidget);
  });

  testWidgets('Trocar para a aba "Minha ficha" mostra o estado sem anamnese', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TreinoScreen()));

    await tester.tap(find.text('Mi rutina'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Completa la anamnesis'), findsOneWidget);
  });
}
