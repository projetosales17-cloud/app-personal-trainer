import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/screens/sua_loja_screen.dart';
import 'package:app_personal_trainer/services/sua_loja_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  SuaLojaScreen tela() => SuaLojaScreen(
    repositorio: SuaLojaRepository(firestore: firestore, uidAtual: () => 'u1'),
  );

  // A tela é uma lista longa + um bottom sheet com formulário; uma
  // superfície alta deixa tudo visível sem depender de rolagem frágil.
  Future<void> montar(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(600, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(home: tela()));
  }

  setUp(() => firestore = FakeFirebaseFirestore());

  testWidgets('Mostra o teaser e o aviso de anunciantes independentes', (tester) async {
    await montar(tester);

    expect(find.text('Tu Tienda'), findsWidgets);
    expect(find.textContaining('escaparate de esas marcas'), findsOneWidget);
    expect(find.textContaining('anunciantes independientes'), findsOneWidget);
    expect(find.byKey(const Key('botao-quero-anunciar')), findsOneWidget);
  });

  testWidgets('O botão de enviar fica desabilitado até preencher o obrigatório', (tester) async {
    await montar(tester);

    await tester.tap(find.byKey(const Key('botao-quero-anunciar')));
    await tester.pumpAndSettle();

    FilledButton enviar() =>
        tester.widget<FilledButton>(find.byKey(const Key('botao-enviar-interesse')));
    expect(enviar().onPressed, isNull);

    await tester.enterText(find.byKey(const Key('campo-nome-marca')), 'Marca de Bia');
    await tester.enterText(find.byKey(const Key('campo-contato')), '11999998888');
    await tester.enterText(find.byKey(const Key('campo-o-que-vende')), 'Ropa fitness');
    await tester.pump();
    // Ainda falta marcar o consentimento.
    expect(enviar().onPressed, isNull);

    await tester.tap(find.byKey(const Key('check-contato')));
    await tester.pump();
    expect(enviar().onPressed, isNotNull);
  });

  testWidgets('Enviar grava o interesse no Firestore e confirma', (tester) async {
    await montar(tester);

    await tester.tap(find.byKey(const Key('botao-quero-anunciar')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('campo-nome-marca')), 'Marca de Bia');
    await tester.enterText(find.byKey(const Key('campo-contato')), 'bia@ejemplo.com');
    await tester.enterText(find.byKey(const Key('campo-o-que-vende')), 'Cosméticos naturales');
    await tester.enterText(find.byKey(const Key('campo-links')), 'instagram.com/bia');
    await tester.tap(find.byKey(const Key('check-contato')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('botao-enviar-interesse')));
    await tester.pumpAndSettle();

    final snap = await firestore.collection('interesse_sua_loja').get();
    expect(snap.docs, hasLength(1));
    expect(snap.docs.first.data()['nomeMarca'], 'Marca de Bia');

    expect(find.textContaining('Recibimos tu interés'), findsOneWidget);
  });
}
