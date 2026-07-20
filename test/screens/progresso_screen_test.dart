import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/screens/progresso_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Mostra a aba "Peso" por padrão', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProgressoScreen()));
    await tester.pump();

    expect(find.textContaining('Nenhum registro de peso ainda'), findsOneWidget);
  });

  testWidgets('Trocar para a aba "Medidas" mostra o formulário de medidas', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProgressoScreen()));
    await tester.pump();

    await tester.tap(find.text('Medidas'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nenhum registro de medidas ainda'), findsOneWidget);
    expect(find.byKey(const Key('campo-cintura')), findsOneWidget);
  });

  testWidgets('Trocar para a aba "Fotos" mostra o estado vazio', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProgressoScreen()));
    await tester.pump();

    await tester.tap(find.text('Fotos'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nenhuma foto ainda'), findsOneWidget);
  });
}
