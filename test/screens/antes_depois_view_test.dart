import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/screens/antes_depois_view.dart';
import 'package:app_personal_trainer/screens/foto_detalhe_screen.dart';
import 'package:app_personal_trainer/services/progresso_repository.dart';

const _pngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';

void main() {
  late Uint8List bytesFoto;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    bytesFoto = base64Decode(_pngBase64);
  });

  ProgressoRepository criarRepositorio() => ProgressoRepository(uidAtual: () => null);

  testWidgets('Com menos de 2 fotos, pede para registrar mais', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AntesDepoisView(repositorio: criarRepositorio()))),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Registre pelo menos duas fotos'), findsOneWidget);
  });

  testWidgets('Com 2 fotos, mostra os cartões "Antes" e "Depois"', (tester) async {
    final repositorio = criarRepositorio();
    await repositorio.registrarFoto(bytesFoto);
    await repositorio.registrarFoto(bytesFoto);

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AntesDepoisView(repositorio: repositorio))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Antes'), findsOneWidget);
    expect(find.text('Depois'), findsOneWidget);
    expect(find.textContaining('Registre pelo menos duas fotos'), findsNothing);
  });

  testWidgets('Com 3 fotos, a linha do tempo mostra todas elas', (tester) async {
    final repositorio = criarRepositorio();
    await repositorio.registrarFoto(bytesFoto);
    await repositorio.registrarFoto(bytesFoto);
    await repositorio.registrarFoto(bytesFoto);

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AntesDepoisView(repositorio: repositorio))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Linha do tempo completa'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('linha-do-tempo')),
        matching: find.byType(Image),
      ),
      findsNWidgets(3),
    );
  });

  testWidgets('Tocar numa foto da linha do tempo abre o detalhe em tela cheia', (tester) async {
    final repositorio = criarRepositorio();
    await repositorio.registrarFoto(bytesFoto);
    await repositorio.registrarFoto(bytesFoto);

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AntesDepoisView(repositorio: repositorio))),
    );
    await tester.pumpAndSettle();

    final primeiraFotoDaLinha = find
        .descendant(of: find.byKey(const Key('linha-do-tempo')), matching: find.byType(GestureDetector))
        .first;
    await tester.ensureVisible(primeiraFotoDaLinha);
    await tester.tap(primeiraFotoDaLinha);
    await tester.pumpAndSettle();

    expect(find.byType(FotoDetalheScreen), findsOneWidget);
  });
}
