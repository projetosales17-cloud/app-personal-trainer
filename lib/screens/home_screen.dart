import 'package:flutter/material.dart';

import 'placeholder_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      titulo: 'Início',
      descricao:
          'Aqui vão os cards de treino do dia, alimentação do dia, '
          'progresso e mensagem motivacional.',
    );
  }
}
