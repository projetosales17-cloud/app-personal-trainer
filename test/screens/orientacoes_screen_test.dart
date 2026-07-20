import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/screens/orientacoes_screen.dart';

void main() {
  testWidgets('Mostra a primeira orientação da lista por padrão (sem filtro)', (tester) async {
    await tester.pumpWidget(MaterialApp(home: OrientacoesScreen()));

    expect(find.text('Por que aquecer antes de treinar'), findsOneWidget);
  });

  testWidgets('Filtrar por tema mostra só as orientações daquele tema', (tester) async {
    await tester.pumpWidget(MaterialApp(home: OrientacoesScreen()));

    await tester.drag(find.byKey(const Key('filtro-temas')), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Hábitos saudáveis'));
    await tester.pumpAndSettle();

    expect(find.text('Sono e recuperação'), findsOneWidget);
    expect(find.text('Por que aquecer antes de treinar'), findsNothing);
  });

  testWidgets('Buscar por palavra-chave filtra a lista', (tester) async {
    await tester.pumpWidget(MaterialApp(home: OrientacoesScreen()));

    await tester.enterText(find.byKey(const Key('campo-busca-orientacoes')), 'menopausa');
    await tester.pump();

    expect(find.text('Atividade física na menopausa'), findsOneWidget);
    expect(find.text('Por que aquecer antes de treinar'), findsNothing);
  });

  testWidgets('Busca sem correspondência mostra estado vazio', (tester) async {
    await tester.pumpWidget(MaterialApp(home: OrientacoesScreen()));

    await tester.enterText(find.byKey(const Key('campo-busca-orientacoes')), 'xyzabc123');
    await tester.pump();

    expect(find.text('Nenhum conteúdo encontrado.'), findsOneWidget);
  });

  testWidgets('Tocar em uma orientação abre a tela de detalhe', (tester) async {
    await tester.pumpWidget(MaterialApp(home: OrientacoesScreen()));

    await tester.tap(find.text('Por que aquecer antes de treinar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('aumenta'), findsOneWidget);
  });
}
