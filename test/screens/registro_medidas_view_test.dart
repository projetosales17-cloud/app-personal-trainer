import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/models/registro_medidas.dart';
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

  testWidgets('Editar pelo menu troca uma medida e pode limpar outra', (tester) async {
    final repositorio = ProgressoRepository();
    await repositorio.registrarMedidas(
      RegistroMedidas(data: DateTime(2026, 1, 1), cinturaCm: 80, quadrilCm: 100),
    );
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: RegistroMedidasView(repositorio: repositorio))),
    );
    await tester.pumpAndSettle();

    final registro = (await repositorio.listarMedidas()).single;
    await tester.tap(find.byKey(Key('menu-medidas-${registro.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('editar-campo-cintura')), '78');
    await tester.enterText(find.byKey(const Key('editar-campo-quadril')), '');
    await tester.tap(find.byKey(const Key('editar-salvar-medidas')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Cintura 78cm'), findsOneWidget);
    final atualizado = (await repositorio.listarMedidas()).single;
    expect(atualizado.cinturaCm, 78);
    expect(atualizado.quadrilCm, isNull);
  });

  testWidgets('Apagar pelo menu pede confirmação e remove da lista', (tester) async {
    final repositorio = ProgressoRepository();
    await repositorio.registrarMedidas(RegistroMedidas(data: DateTime(2026, 1, 1), bracoCm: 30));
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: RegistroMedidasView(repositorio: repositorio))),
    );
    await tester.pumpAndSettle();

    final registro = (await repositorio.listarMedidas()).single;
    await tester.tap(find.byKey(Key('menu-medidas-${registro.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apagar').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmar-apagar-medidas')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nenhum registro de medidas ainda'), findsOneWidget);
    expect(await repositorio.listarMedidas(), isEmpty);
  });
}
