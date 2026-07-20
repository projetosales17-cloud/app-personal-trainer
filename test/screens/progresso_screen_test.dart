import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/screens/progresso_screen.dart';
import 'package:app_personal_trainer/services/progresso_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Sem registros, mostra estado vazio', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ProgressoScreen()));
    await tester.pump();

    expect(find.textContaining('Nenhum registro de peso ainda'), findsOneWidget);
  });

  testWidgets('Registrar um peso adiciona à lista e limpa o campo', (tester) async {
    final repositorio = ProgressoRepository();
    await tester.pumpWidget(MaterialApp(home: ProgressoScreen(repositorio: repositorio)));
    await tester.pump();

    await tester.enterText(find.byKey(const Key('campo-peso')), '68,5');
    await tester.tap(find.byKey(const Key('botao-registrar-peso')));
    await tester.pumpAndSettle();

    expect(find.text('68.5 kg'), findsOneWidget);

    final campo = tester.widget<TextField>(find.byKey(const Key('campo-peso')));
    expect(campo.controller!.text, isEmpty);
  });

  testWidgets('Múltiplos registros aparecem em ordem do mais recente para o mais antigo', (
    tester,
  ) async {
    final repositorio = ProgressoRepository();
    await repositorio.registrarPeso(70, data: DateTime(2026, 1, 1));
    await repositorio.registrarPeso(69, data: DateTime(2026, 1, 8));

    await tester.pumpWidget(MaterialApp(home: ProgressoScreen(repositorio: repositorio)));
    await tester.pump();

    final tiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
    expect((tiles.first.title as Text).data, '69.0 kg');
    expect((tiles.last.title as Text).data, '70.0 kg');
  });

  testWidgets('Texto inválido no campo de peso não registra nada', (tester) async {
    final repositorio = ProgressoRepository();
    await tester.pumpWidget(MaterialApp(home: ProgressoScreen(repositorio: repositorio)));
    await tester.pump();

    await tester.enterText(find.byKey(const Key('campo-peso')), 'abc');
    await tester.tap(find.byKey(const Key('botao-registrar-peso')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nenhum registro de peso ainda'), findsOneWidget);
  });
}
