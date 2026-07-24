import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/screens/vitrine_produtos_screen.dart';

void main() {
  testWidgets('Mostra os produtos do catálogo com faixa de preço e tags', (tester) async {
    await tester.pumpWidget(MaterialApp(home: VitrineProdutosScreen()));

    expect(find.text('Kit de faixas de resistência'), findsOneWidget);
    expect(find.text('Roda abdominal'), findsOneWidget);
    expect(find.text('Terceira idade'), findsWidgets);
  });

  testWidgets('Sem link externo ainda, o botão de compra fica desabilitado e mostra "Em breve"', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: VitrineProdutosScreen()));

    final botoes = tester.widgetList<FilledButton>(
      find.widgetWithText(FilledButton, 'Em breve'),
    );
    expect(botoes, isNotEmpty);
    for (final botao in botoes) {
      expect(botao.onPressed, isNull);
    }
    expect(find.widgetWithText(FilledButton, 'Comprar'), findsNothing);
  });

  testWidgets('Mostra o aviso de catálogo informativo', (tester) async {
    await tester.pumpWidget(MaterialApp(home: VitrineProdutosScreen()));

    expect(find.textContaining('Catálogo informativo'), findsOneWidget);
  });
}
