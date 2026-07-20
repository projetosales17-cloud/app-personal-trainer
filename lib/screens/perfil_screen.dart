import 'package:flutter/material.dart';

import 'placeholder_screen.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      titulo: 'Perfil',
      descricao:
          'Aqui vão os dados da anamnese, notificações, assinatura/licença '
          'e suporte.',
    );
  }
}
