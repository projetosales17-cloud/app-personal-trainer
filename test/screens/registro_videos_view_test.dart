import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/screens/registro_videos_view.dart';
import 'package:app_personal_trainer/services/progresso_repository.dart';

const _pngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';

void main() {
  late Directory diretorioAppTemp;
  late Directory diretorioOrigemTemp;
  late File arquivoOrigem;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    diretorioAppTemp = await Directory.systemTemp.createTemp('videos_app_test_');
    diretorioOrigemTemp = await Directory.systemTemp.createTemp('videos_origem_test_');
    arquivoOrigem = File('${diretorioOrigemTemp.path}/video_selecionado.mp4');
    // Não precisa ser um vídeo de verdade — a tela de registro só copia e
    // guarda o caminho do arquivo, não decodifica nada (isso só acontece
    // na reprodução, em VideoDetalheScreen, fora do escopo deste teste).
    await arquivoOrigem.writeAsBytes(base64Decode(_pngBase64));
  });

  tearDown(() async {
    for (final dir in [diretorioAppTemp, diretorioOrigemTemp]) {
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    }
  });

  // gerarMiniaturaVideo real faz chamada de platform channel — sem handler
  // registrado no ambiente de teste, o que quebraria registrarVideo.
  // Injetamos um fake que não faz nada por padrão; o teste dedicado à
  // miniatura injeta o seu próprio.
  ProgressoRepository criarRepositorio() => ProgressoRepository(
    resolverDiretorioBase: () async => diretorioAppTemp,
    gerarMiniaturaVideo: (_, _) async => null,
  );

  testWidgets('Sem vídeos, mostra estado vazio', (tester) async {
    final repositorio = criarRepositorio();
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: RegistroVideosView(repositorio: repositorio))),
    );
    await tester.pump();

    expect(find.textContaining('Nenhum vídeo ainda'), findsOneWidget);
  });

  testWidgets('Com um vídeo já registrado, mostra na lista', (tester) async {
    final repositorio = criarRepositorio();
    // registrarVideo faz E/S real de arquivo — precisa de runAsync() dentro
    // de um testWidgets, mesmo antes do pumpWidget.
    await tester.runAsync(() => repositorio.registrarVideo(arquivoOrigem));

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: RegistroVideosView(repositorio: repositorio))),
    );
    await tester.pump();

    expect(find.textContaining('Nenhum vídeo ainda'), findsNothing);
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
  });

  testWidgets('Com miniatura gerada, mostra a imagem em vez do ícone genérico', (tester) async {
    final repositorio = ProgressoRepository(
      resolverDiretorioBase: () async => diretorioAppTemp,
      gerarMiniaturaVideo: (caminhoVideo, pastaDestino) async {
        final miniatura = File('$pastaDestino/miniatura.jpg');
        await miniatura.writeAsBytes(base64Decode(_pngBase64));
        return miniatura.path;
      },
    );
    await tester.runAsync(() => repositorio.registrarVideo(arquivoOrigem));

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: RegistroVideosView(repositorio: repositorio))),
    );
    await tester.pump();

    expect(find.byIcon(Icons.play_circle_outline), findsNothing);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('Tocar em "Câmera" aciona o seletor com a fonte câmera', (tester) async {
    ImageSource? fonteRecebida;
    final repositorio = criarRepositorio();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegistroVideosView(
            repositorio: repositorio,
            selecionarVideo: (fonte) async {
              fonteRecebida = fonte;
              return null;
            },
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('botao-camera-video')));
    await tester.pumpAndSettle();

    expect(fonteRecebida, ImageSource.camera);
    expect(find.textContaining('Nenhum vídeo ainda'), findsOneWidget);
  });

  testWidgets('Tocar em "Galeria" aciona o seletor com a fonte galeria', (tester) async {
    ImageSource? fonteRecebida;
    final repositorio = criarRepositorio();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegistroVideosView(
            repositorio: repositorio,
            selecionarVideo: (fonte) async {
              fonteRecebida = fonte;
              return null;
            },
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('botao-galeria-video')));
    await tester.pumpAndSettle();

    expect(fonteRecebida, ImageSource.gallery);
  });

  testWidgets('Cancelar a seleção (retorna null) não adiciona nada', (tester) async {
    final repositorio = criarRepositorio();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegistroVideosView(
            repositorio: repositorio,
            selecionarVideo: (_) async => null,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('botao-camera-video')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nenhum vídeo ainda'), findsOneWidget);
  });
}
