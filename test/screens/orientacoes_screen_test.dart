import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/screens/orientacoes_screen.dart';

void main() {
  testWidgets('Mostra a primeira orientação da lista por padrão (sem filtro)', (tester) async {
    await tester.pumpWidget(MaterialApp(home: OrientacoesScreen()));

    expect(find.text('Por qué calentar antes de entrenar'), findsOneWidget);
  });

  testWidgets('Filtrar por tema mostra só as orientações daquele tema', (tester) async {
    await tester.pumpWidget(MaterialApp(home: OrientacoesScreen()));

    await tester.dragUntilVisible(
      find.widgetWithText(FilterChip, 'Hábitos saludables'),
      find.byKey(const Key('filtro-temas')),
      const Offset(-100, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Hábitos saludables'));
    await tester.pumpAndSettle();

    expect(find.text('Sueño y recuperación'), findsOneWidget);
    expect(find.text('Por qué calentar antes de entrenar'), findsNothing);
  });

  testWidgets('Buscar por palavra-chave filtra a lista', (tester) async {
    await tester.pumpWidget(MaterialApp(home: OrientacoesScreen()));

    await tester.enterText(find.byKey(const Key('campo-busca-orientacoes')), 'menopausia');
    await tester.pump();

    expect(find.text('Actividad física en la menopausia'), findsOneWidget);
    expect(find.text('Por qué calentar antes de entrenar'), findsNothing);
  });

  testWidgets('Busca sem correspondência mostra estado vazio', (tester) async {
    await tester.pumpWidget(MaterialApp(home: OrientacoesScreen()));

    await tester.enterText(find.byKey(const Key('campo-busca-orientacoes')), 'xyzabc123');
    await tester.pump();

    expect(find.text('No se encontró contenido.'), findsOneWidget);
  });

  testWidgets('Tocar em uma orientação abre a tela de detalhe', (tester) async {
    await tester.pumpWidget(MaterialApp(home: OrientacoesScreen()));

    await tester.tap(find.text('Por qué calentar antes de entrenar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('aumenta'), findsOneWidget);
  });

  testWidgets('Filtrar por tipo FAQ mostra só perguntas frequentes', (tester) async {
    await tester.pumpWidget(MaterialApp(home: OrientacoesScreen()));

    await tester.tap(find.widgetWithText(ChoiceChip, 'FAQ'));
    await tester.pumpAndSettle();

    expect(find.text('¿Cuántas veces por semana debo entrenar?'), findsOneWidget);
    expect(find.text('Por qué calentar antes de entrenar'), findsNothing);
  });

  testWidgets('Item de FAQ mostra o selo "FAQ" no subtítulo', (tester) async {
    await tester.pumpWidget(MaterialApp(home: OrientacoesScreen()));

    await tester.tap(find.widgetWithText(ChoiceChip, 'FAQ'));
    await tester.pumpAndSettle();

    expect(find.textContaining('FAQ ·'), findsWidgets);
  });
}
