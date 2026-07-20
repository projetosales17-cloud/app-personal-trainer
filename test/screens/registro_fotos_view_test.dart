import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/screens/registro_fotos_view.dart';
import 'package:app_personal_trainer/services/progresso_repository.dart';

const _pngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';

void main() {
  late Directory diretorioAppTemp;
  late Directory diretorioOrigemTemp;
  late File arquivoOrigem;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    diretorioAppTemp = await Directory.systemTemp.createTemp('fotos_app_test_');
    diretorioOrigemTemp = await Directory.systemTemp.createTemp('fotos_origem_test_');
    arquivoOrigem = File('${diretorioOrigemTemp.path}/foto_selecionada.png');
    await arquivoOrigem.writeAsBytes(base64Decode(_pngBase64));
  });

  tearDown(() async {
    for (final dir in [diretorioAppTemp, diretorioOrigemTemp]) {
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    }
  });

  testWidgets('Sem fotos, mostra estado vazio', (tester) async {
    final repositorio = ProgressoRepository(resolverDiretorioBase: () async => diretorioAppTemp);
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: RegistroFotosView(repositorio: repositorio))),
    );
    await tester.pump();

    expect(find.textContaining('Nenhuma foto ainda'), findsOneWidget);
  });

  testWidgets('Com uma foto já registrada, mostra a grade', (tester) async {
    final repositorio = ProgressoRepository(resolverDiretorioBase: () async => diretorioAppTemp);
    // registrarFoto faz E/S real de arquivo (File.copy) — dentro de um
    // testWidgets isso precisa de runAsync(), mesmo antes do pumpWidget,
    // senão trava para sempre (o binding de teste não libera callbacks de
    // E/S real fora desse escopo).
    await tester.runAsync(() => repositorio.registrarFoto(arquivoOrigem));

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: RegistroFotosView(repositorio: repositorio))),
    );
    await tester.pump();

    expect(find.textContaining('Nenhuma foto ainda'), findsNothing);
    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('Tocar em "Câmera" aciona o seletor com a fonte câmera', (tester) async {
    ImageSource? fonteRecebida;
    final repositorio = ProgressoRepository(resolverDiretorioBase: () async => diretorioAppTemp);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegistroFotosView(
            repositorio: repositorio,
            selecionarImagem: (fonte) async {
              fonteRecebida = fonte;
              return null;
            },
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('botao-camera')));
    await tester.pumpAndSettle();

    expect(fonteRecebida, ImageSource.camera);
    expect(find.textContaining('Nenhuma foto ainda'), findsOneWidget);
  });

  testWidgets('Tocar em "Galeria" aciona o seletor com a fonte galeria', (tester) async {
    ImageSource? fonteRecebida;
    final repositorio = ProgressoRepository(resolverDiretorioBase: () async => diretorioAppTemp);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegistroFotosView(
            repositorio: repositorio,
            selecionarImagem: (fonte) async {
              fonteRecebida = fonte;
              return null;
            },
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('botao-galeria')));
    await tester.pumpAndSettle();

    expect(fonteRecebida, ImageSource.gallery);
  });

  testWidgets('Cancelar a seleção (retorna null) não adiciona nada', (tester) async {
    final repositorio = ProgressoRepository(resolverDiretorioBase: () async => diretorioAppTemp);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegistroFotosView(
            repositorio: repositorio,
            selecionarImagem: (_) async => null,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('botao-camera')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nenhuma foto ainda'), findsOneWidget);
  });
}
