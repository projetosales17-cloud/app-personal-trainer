import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/app.dart';

void main() {
  testWidgets('App abre na tela Início com a navegação principal', (tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Início'), findsWidgets);
    expect(find.byIcon(Icons.fitness_center_outlined), findsOneWidget);
  });

  testWidgets('Navegar para a aba Treino troca de tela', (tester) async {
    await tester.pumpWidget(const App());

    await tester.tap(find.byIcon(Icons.fitness_center_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Treino'), findsWidgets);
  });

  testWidgets('Todas as 6 abas da navegação estão presentes', (tester) async {
    await tester.pumpWidget(const App());

    expect(find.byType(NavigationDestination), findsNWidgets(6));
  });
}
