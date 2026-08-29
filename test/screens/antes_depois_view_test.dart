import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/models/registro_foto.dart';
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

  testWidgets('Sem 2 fotos do mesmo ângulo, pede para registrar mais', (tester) async {
    final repositorio = criarRepositorio();
    // Uma de cada ângulo — nenhum ângulo tem 2.
    await repositorio.registrarFoto(bytesFoto, pose: PoseFoto.frente);
    await repositorio.registrarFoto(bytesFoto, pose: PoseFoto.costas);

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AntesDepoisView(repositorio: repositorio))),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Registra al menos dos fotos'), findsOneWidget);
  });

  testWidgets('Com 2 fotos do mesmo ângulo, mostra a seção com "Antes" e "Depois"', (tester) async {
    final repositorio = criarRepositorio();
    await repositorio.registrarFoto(bytesFoto, pose: PoseFoto.frente);
    await repositorio.registrarFoto(bytesFoto, pose: PoseFoto.frente);

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AntesDepoisView(repositorio: repositorio))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Frente'), findsOneWidget);
    expect(find.text('Antes'), findsOneWidget);
    expect(find.text('Después'), findsOneWidget);
    expect(find.textContaining('Registra al menos dos fotos'), findsNothing);
  });

  testWidgets('Ângulos diferentes viram seções separadas', (tester) async {
    final repositorio = criarRepositorio();
    await repositorio.registrarFoto(bytesFoto, pose: PoseFoto.frente);
    await repositorio.registrarFoto(bytesFoto, pose: PoseFoto.frente);
    await repositorio.registrarFoto(bytesFoto, pose: PoseFoto.costas);
    await repositorio.registrarFoto(bytesFoto, pose: PoseFoto.costas);

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AntesDepoisView(repositorio: repositorio))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Frente'), findsOneWidget);
    expect(find.text('Espalda'), findsOneWidget);
    expect(find.text('Antes'), findsNWidgets(2));
  });

  testWidgets('A linha do tempo do ângulo mostra todas as fotos dele', (tester) async {
    final repositorio = criarRepositorio();
    await repositorio.registrarFoto(bytesFoto, pose: PoseFoto.lado);
    await repositorio.registrarFoto(bytesFoto, pose: PoseFoto.lado);
    await repositorio.registrarFoto(bytesFoto, pose: PoseFoto.lado);

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AntesDepoisView(repositorio: repositorio))),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('linha-do-tempo-lado')),
        matching: find.byType(Image),
      ),
      findsNWidgets(3),
    );
  });

  testWidgets('Tocar numa foto da linha do tempo abre o detalhe em tela cheia', (tester) async {
    final repositorio = criarRepositorio();
    await repositorio.registrarFoto(bytesFoto, pose: PoseFoto.frente);
    await repositorio.registrarFoto(bytesFoto, pose: PoseFoto.frente);

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AntesDepoisView(repositorio: repositorio))),
    );
    await tester.pumpAndSettle();

    final primeiraFotoDaLinha = find
        .descendant(
          of: find.byKey(const Key('linha-do-tempo-frente')),
          matching: find.byType(GestureDetector),
        )
        .first;
    await tester.ensureVisible(primeiraFotoDaLinha);
    await tester.tap(primeiraFotoDaLinha);
    await tester.pumpAndSettle();

    expect(find.byType(FotoDetalheScreen), findsOneWidget);
  });
}
