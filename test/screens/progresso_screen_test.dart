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

    expect(find.textContaining('Aún no hay registros de peso'), findsOneWidget);
  });

  testWidgets('Trocar para a aba "Medidas" mostra o formulário de medidas', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProgressoScreen()));
    await tester.pump();

    await tester.tap(find.text('Medidas'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Aún no hay registros de medidas'), findsOneWidget);
    expect(find.byKey(const Key('campo-cintura')), findsOneWidget);
  });

  testWidgets('Trocar para a aba "Fotos" mostra o estado vazio', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProgressoScreen()));
    await tester.pump();

    await tester.tap(find.text('Fotos'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Aún no hay fotos'), findsOneWidget);
  });

  testWidgets('Trocar para a aba "Vídeos" mostra o estado vazio', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProgressoScreen()));
    await tester.pump();

    await tester.drag(find.byType(TabBar), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Videos'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Aún no hay videos'), findsOneWidget);
  });

  testWidgets('Trocar para a aba "Antes/Depois" pede mais fotos', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProgressoScreen()));
    await tester.pump();

    await tester.drag(find.byType(TabBar), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Antes/Después'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Registra al menos dos fotos'), findsOneWidget);
  });
}
