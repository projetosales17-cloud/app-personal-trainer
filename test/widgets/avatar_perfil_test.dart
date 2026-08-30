import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/widgets/avatar_perfil.dart';

// 1x1 PNG.
const _png =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';

void main() {
  testWidgets('Sem foto, mostra as iniciais do nome', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AvatarPerfil(dataUri: null, nome: 'Maria Silva')),
      ),
    );

    expect(find.byKey(const Key('avatar-perfil-iniciais')), findsOneWidget);
    expect(find.text('MS'), findsOneWidget);
  });

  testWidgets('Sem foto e sem nome, mostra o ícone genérico', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AvatarPerfil(dataUri: null, nome: ''))),
    );

    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets('Com foto, mostra a imagem', (tester) async {
    final dataUri = 'data:image/png;base64,$_png';
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AvatarPerfil(dataUri: dataUri, nome: 'Maria'))),
    );

    expect(find.byKey(const Key('avatar-perfil-foto')), findsOneWidget);
    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.backgroundImage, isA<MemoryImage>());
    final img = avatar.backgroundImage! as MemoryImage;
    expect(img.bytes, base64Decode(_png));
    expect(img.bytes, isA<Uint8List>());
  });
}
