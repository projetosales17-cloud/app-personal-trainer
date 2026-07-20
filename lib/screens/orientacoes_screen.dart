import 'package:flutter/material.dart';

import 'placeholder_screen.dart';

class OrientacoesScreen extends StatelessWidget {
  const OrientacoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      titulo: 'Orientações',
      descricao:
          'Aqui vai a biblioteca de conteúdo pré-gravado (texto/vídeo), '
          'com busca por tema.',
    );
  }
}
