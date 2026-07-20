import 'package:flutter/material.dart';

import 'placeholder_screen.dart';

class AlimentacaoScreen extends StatelessWidget {
  const AlimentacaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      titulo: 'Alimentação',
      descricao:
          'Aqui vão o cardápio do dia/semana, substituição de alimentos, '
          'diário alimentar, hidratação, receitas e suplementação.',
    );
  }
}
