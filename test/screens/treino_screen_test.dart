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

    expect(find.text('Flexão de braço'), findsOneWidget);
  });

  testWidgets('É possível rolar até exercícios mais abaixo na lista', (tester) async {
    await tester.pumpWidget(MaterialApp(home: TreinoScreen()));

    await tester.dragUntilVisible(
      find.text('Prancha'),
      find.byKey(_lista),
      const Offset(0, -300),
    );

    expect(find.text('Prancha'), findsOneWidget);
  });

  testWidgets('Filtrar por grupo muscular mostra só os exercícios daquele grupo', (tester) async {
    await tester.pumpWidget(MaterialApp(home: TreinoScreen()));

    // Rola a lista horizontal de filtros o suficiente para o chip "Glúteo"
    // ficar bem dentro da área visível (não só na borda do cache extent).
    await tester.drag(find.byKey(const Key('filtro-grupos')), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Glúteo'));
    await tester.pumpAndSettle();

    expect(find.text('Elevação pélvica'), findsOneWidget);
    expect(find.text('Flexão de braço'), findsNothing);
  });

  testWidgets('Tocar em um exercício abre a tela de detalhe', (tester) async {
    await tester.pumpWidget(MaterialApp(home: TreinoScreen()));

    await tester.tap(find.text('Flexão de braço'));
    await tester.pumpAndSettle();

    expect(find.text('Como executar'), findsOneWidget);
    expect(find.textContaining('largura dos ombros'), findsOneWidget);
  });

  testWidgets('Trocar para a aba "Minha ficha" mostra o estado sem anamnese', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TreinoScreen()));

    await tester.tap(find.text('Minha ficha'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Complete a anamnese'), findsOneWidget);
  });
}
