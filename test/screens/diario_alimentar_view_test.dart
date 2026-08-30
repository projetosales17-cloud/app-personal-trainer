import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/screens/diario_alimentar_view.dart';
import 'package:app_personal_trainer/services/diario_alimentar_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Sem registros, mostra estado vazio', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: DiarioAlimentarView())));
    await tester.pump();

    expect(find.textContaining('Nenhum registro no diário ainda'), findsOneWidget);
  });

  testWidgets('Registrar uma refeição adiciona à lista e limpa o campo', (tester) async {
    final repositorio = DiarioAlimentarRepository();
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: DiarioAlimentarView(repositorio: repositorio))),
    );
    await tester.pump();

    await tester.enterText(find.byKey(const Key('campo-descricao')), 'Frango com arroz');
    await tester.tap(find.byKey(const Key('botao-registrar-diario')));
    await tester.pumpAndSettle();

    expect(find.text('Frango com arroz'), findsOneWidget);
    expect(find.textContaining('Café da manhã ·'), findsOneWidget);

    final campo = tester.widget<TextField>(find.byKey(const Key('campo-descricao')));
    expect(campo.controller!.text, isEmpty);
  });

  testWidgets('Trocar a refeição selecionada reflete no registro salvo', (tester) async {
    final repositorio = DiarioAlimentarRepository();
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: DiarioAlimentarView(repositorio: repositorio))),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('campo-refeicao')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jantar').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('campo-descricao')), 'Sopa de legumes');
    await tester.tap(find.byKey(const Key('botao-registrar-diario')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Jantar ·'), findsOneWidget);
  });

  testWidgets('Descrição vazia não registra nada', (tester) async {
    final repositorio = DiarioAlimentarRepository();
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: DiarioAlimentarView(repositorio: repositorio))),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('botao-registrar-diario')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nenhum registro no diário ainda'), findsOneWidget);
  });

  Future<void> abrirMenu(WidgetTester tester, DiarioAlimentarRepository repo) async {
    final registro = (await repo.listar()).single;
    await tester.tap(find.byKey(Key('menu-registro-${registro.id}')));
    await tester.pumpAndSettle();
  }

  testWidgets('Editar um registro pelo menu troca a descrição salva', (tester) async {
    final repositorio = DiarioAlimentarRepository();
    await repositorio.registrar('Almoço', 'Frango');
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: DiarioAlimentarView(repositorio: repositorio))),
    );
    await tester.pumpAndSettle();

    await abrirMenu(tester, repositorio);
    await tester.tap(find.text('Editar').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('editar-campo-descricao')), 'Peixe grelhado');
    await tester.tap(find.byKey(const Key('editar-salvar-diario')));
    await tester.pumpAndSettle();

    expect(find.text('Peixe grelhado'), findsOneWidget);
    expect(find.text('Frango'), findsNothing);
    expect((await repositorio.listar()).single.descricao, 'Peixe grelhado');
  });

  testWidgets('Apagar um registro pede confirmação e remove da lista', (tester) async {
    final repositorio = DiarioAlimentarRepository();
    await repositorio.registrar('Almoço', 'Frango');
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: DiarioAlimentarView(repositorio: repositorio))),
    );
    await tester.pumpAndSettle();

    await abrirMenu(tester, repositorio);
    await tester.tap(find.text('Apagar').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('confirmar-apagar-diario')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nenhum registro no diário ainda'), findsOneWidget);
    expect(await repositorio.listar(), isEmpty);
  });
}
