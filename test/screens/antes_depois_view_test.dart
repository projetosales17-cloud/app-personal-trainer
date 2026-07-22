import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/screens/antes_depois_view.dart';
import 'package:app_personal_trainer/screens/foto_detalhe_screen.dart';
import 'package:app_personal_trainer/services/progresso_repository.dart';

const _pngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';

void main() {
  late Directory diretorioAppTemp;
  late Directory diretorioOrigemTemp;
  late File arquivoOrigem;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    diretorioAppTemp = await Directory.systemTemp.createTemp('antes_depois_app_test_');
    diretorioOrigemTemp = await Directory.systemTemp.createTemp('antes_depois_origem_test_');
    arquivoOrigem = File('${diretorioOrigemTemp.path}/foto.png');
    await arquivoOrigem.writeAsBytes(base64Decode(_pngBase64));
  });

  tearDown(() async {
    for (final dir in [diretorioAppTemp, diretorioOrigemTemp]) {
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    }
  });

  testWidgets('Com menos de 2 fotos, pede para registrar mais', (tester) async {
    final repositorio = ProgressoRepository(resolverDiretorioBase: () async => diretorioAppTemp);
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AntesDepoisView(repositorio: repositorio))),
    );
    await tester.pump();

    expect(find.textContaining('Registre pelo menos duas fotos'), findsOneWidget);
  });

  testWidgets('Com 2 fotos, mostra os cartões "Antes" e "Depois"', (tester) async {
    final repositorio = ProgressoRepository(resolverDiretorioBase: () async => diretorioAppTemp);
    await tester.runAsync(() async {
      await repositorio.registrarFoto(arquivoOrigem);
      await repositorio.registrarFoto(arquivoOrigem);
    });

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AntesDepoisView(repositorio: repositorio))),
    );
    await tester.pump();

    expect(find.text('Antes'), findsOneWidget);
    expect(find.text('Depois'), findsOneWidget);
    expect(find.textContaining('Registre pelo menos duas fotos'), findsNothing);
  });

  testWidgets('Com 3 fotos, a linha do tempo mostra todas elas', (tester) async {
    final repositorio = ProgressoRepository(resolverDiretorioBase: () async => diretorioAppTemp);
    await tester.runAsync(() async {
      await repositorio.registrarFoto(arquivoOrigem);
      await repositorio.registrarFoto(arquivoOrigem);
      await repositorio.registrarFoto(arquivoOrigem);
    });

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AntesDepoisView(repositorio: repositorio))),
    );
    await tester.pump();

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
    final repositorio = ProgressoRepository(resolverDiretorioBase: () async => diretorioAppTemp);
    await tester.runAsync(() async {
      await repositorio.registrarFoto(arquivoOrigem);
      await repositorio.registrarFoto(arquivoOrigem);
    });

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AntesDepoisView(repositorio: repositorio))),
    );
    await tester.pump();

    final primeiraFotoDaLinha = find
        .descendant(of: find.byKey(const Key('linha-do-tempo')), matching: find.byType(GestureDetector))
        .first;
    await tester.ensureVisible(primeiraFotoDaLinha);
    await tester.tap(primeiraFotoDaLinha);
    await tester.pumpAndSettle();

    expect(find.byType(FotoDetalheScreen), findsOneWidget);
  });
}
