import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/models/registro_foto.dart';
import 'package:app_personal_trainer/screens/registro_fotos_view.dart';
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

  testWidgets('Sem fotos, mostra estado vazio', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: RegistroFotosView(repositorio: criarRepositorio()))),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Nenhuma foto ainda'), findsOneWidget);
  });

  testWidgets('Com uma foto já registrada, mostra a grade', (tester) async {
    final repositorio = criarRepositorio();
    await repositorio.registrarFoto(bytesFoto);

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: RegistroFotosView(repositorio: repositorio))),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Nenhuma foto ainda'), findsNothing);
    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('Selecionar uma imagem adiciona a foto à grade', (tester) async {
    final repositorio = criarRepositorio();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegistroFotosView(
            repositorio: repositorio,
            selecionarImagem: (_) async => bytesFoto,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('botao-galeria')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nenhuma foto ainda'), findsNothing);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('Tocar em "Câmera" aciona o seletor com a fonte câmera', (tester) async {
    ImageSource? fonteRecebida;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegistroFotosView(
            repositorio: criarRepositorio(),
            selecionarImagem: (fonte) async {
              fonteRecebida = fonte;
              return null;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('botao-camera')));
    await tester.pumpAndSettle();

    expect(fonteRecebida, ImageSource.camera);
    expect(find.textContaining('Nenhuma foto ainda'), findsOneWidget);
  });

  testWidgets('Tocar em "Galeria" aciona o seletor com a fonte galeria', (tester) async {
    ImageSource? fonteRecebida;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegistroFotosView(
            repositorio: criarRepositorio(),
            selecionarImagem: (fonte) async {
              fonteRecebida = fonte;
              return null;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('botao-galeria')));
    await tester.pumpAndSettle();

    expect(fonteRecebida, ImageSource.gallery);
  });

  testWidgets('Escolher o ângulo "Costas" grava a foto com esse ângulo', (tester) async {
    final repositorio = criarRepositorio();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegistroFotosView(
            repositorio: repositorio,
            selecionarImagem: (_) async => bytesFoto,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('chip-pose-costas')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('botao-galeria')));
    await tester.pumpAndSettle();

    final fotos = await repositorio.listarFotos();
    expect(fotos.single.pose, PoseFoto.costas);
  });

  testWidgets('Apagar a foto some da grade na hora, sem trocar de aba', (tester) async {
    final repositorio = criarRepositorio();
    await repositorio.registrarFoto(bytesFoto);

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: RegistroFotosView(repositorio: repositorio))),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsOneWidget);

    await tester.tap(find.byType(Image));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('botao-apagar-foto')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apagar'));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsNothing);
    expect(find.textContaining('Nenhuma foto ainda'), findsOneWidget);
  });

  testWidgets('Trocar o ângulo da foto pela tela de detalhe salva o novo ângulo', (tester) async {
    final repositorio = criarRepositorio();
    await repositorio.registrarFoto(bytesFoto, pose: PoseFoto.frente);

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: RegistroFotosView(repositorio: repositorio))),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Image));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('botao-trocar-angulo-foto')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('opcao-pose-costas')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Costas ·'), findsOneWidget);
    expect((await repositorio.listarFotos()).single.pose, PoseFoto.costas);
  });

  testWidgets('O "?" abre a folha de ajuda com orientação de roupa', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: RegistroFotosView(repositorio: criarRepositorio()))),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('botao-ajuda-fotos-progresso')));
    await tester.pumpAndSettle();

    expect(find.text('Roupa justa ou biquíni'), findsOneWidget);
    expect(find.textContaining('Mesmo ângulo sempre'), findsOneWidget);
  });

  testWidgets('Cancelar a seleção (retorna null) não adiciona nada', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegistroFotosView(
            repositorio: criarRepositorio(),
            selecionarImagem: (_) async => null,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('botao-camera')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nenhuma foto ainda'), findsOneWidget);
  });
}
