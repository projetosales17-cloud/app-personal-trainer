import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/screens/registro_medidas_view.dart';
import 'package:app_personal_trainer/services/progresso_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Sem registros, mostra estado vazio', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: RegistroMedidasView())));
    await tester.pump();

    expect(find.textContaining('Nenhum registro de medidas ainda'), findsOneWidget);
  });

  testWidgets('Registrar preenchendo só alguns campos adiciona à lista e limpa o formulário', (
    tester,
  ) async {
    final repositorio = ProgressoRepository();
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: RegistroMedidasView(repositorio: repositorio))),
    );
    await tester.pump();

    await tester.enterText(find.byKey(const Key('campo-cintura')), '80');
    await tester.enterText(find.byKey(const Key('campo-quadril')), '100');
    await tester.tap(find.byKey(const Key('botao-registrar-medidas')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Cintura 80cm'), findsOneWidget);
    expect(find.textContaining('Quadril 100cm'), findsOneWidget);

    final campoCintura = tester.widget<TextField>(find.byKey(const Key('campo-cintura')));
    expect(campoCintura.controller!.text, isEmpty);
  });

  testWidgets('Formulário vazio não registra nada', (tester) async {
    final repositorio = ProgressoRepository();
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: RegistroMedidasView(repositorio: repositorio))),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('botao-registrar-medidas')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nenhum registro de medidas ainda'), findsOneWidget);
  });
}
