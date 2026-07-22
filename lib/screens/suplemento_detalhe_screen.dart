import 'package:flutter/material.dart';

import '../models/suplemento.dart';

class SuplementoDetalheScreen extends StatelessWidget {
  const SuplementoDetalheScreen({super.key, required this.suplemento});

  final Suplemento suplemento;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(suplemento.nome)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Chip(label: Text(suplemento.tipo.label)),
          const SizedBox(height: 24),
          Text(suplemento.descricao, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Conteúdo educativo geral — não recomenda dosagem, horário de uso '
              'ou combinação específica. Consulte um(a) nutricionista ou médico '
              'para orientação individualizada, especialmente se você fez '
              'cirurgia bariátrica ou tem alguma condição de saúde.',
              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
