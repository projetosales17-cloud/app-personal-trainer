import 'package:flutter/material.dart';

import '../models/orientacao.dart';
import 'orientacao_video_screen.dart';

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
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(orientacao.tema.label)),
              if (orientacao.tipo == TipoConteudoOrientacao.faq)
                const Chip(label: Text('FAQ'), visualDensity: VisualDensity.compact),
            ],
          ),
          const SizedBox(height: 24),
          Text(orientacao.corpo, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          if (orientacao.urlVideo == null)
            Text(
              'Vídeo em breve.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrientacaoVideoScreen(
                    titulo: orientacao.titulo,
                    urlVideo: orientacao.urlVideo!,
                  ),
                ),
              ),
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Assistir vídeo'),
            ),
        ],
      ),
    );
  }
}
