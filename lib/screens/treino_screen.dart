import 'package:flutter/material.dart';

import 'placeholder_screen.dart';

class TreinoScreen extends StatelessWidget {
  const TreinoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      titulo: 'Treino',
      descricao:
          'Aqui vão o calendário semanal, a ficha atual, a execução do '
          'exercício (vídeo/GIF, cronômetro de descanso, registro de carga) '
          'e o histórico de treinos.',
    );
  }
}
