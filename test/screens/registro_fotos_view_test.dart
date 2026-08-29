import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
