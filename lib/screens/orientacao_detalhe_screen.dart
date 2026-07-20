import 'package:flutter/material.dart';

import '../models/orientacao.dart';

class OrientacaoDetalheScreen extends StatelessWidget {
  const OrientacaoDetalheScreen({super.key, required this.orientacao});

  final Orientacao orientacao;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(orientacao.titulo)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Chip(label: Text(orientacao.tema.label)),
          const SizedBox(height: 24),
          Text(orientacao.corpo, style: Theme.of(context).textTheme.bodyLarge),
          if (orientacao.urlVideo == null) ...[
            const SizedBox(height: 24),
            Text(
              'Vídeo em breve.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
