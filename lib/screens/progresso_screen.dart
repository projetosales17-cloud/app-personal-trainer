import 'package:flutter/material.dart';

import 'placeholder_screen.dart';

class ProgressoScreen extends StatelessWidget {
  const ProgressoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      titulo: 'Progresso',
      descricao:
          'Aqui vão o registro de peso, medidas, fotos e vídeos '
          '(armazenados localmente), e os gráficos de evolução.',
    );
  }
}
