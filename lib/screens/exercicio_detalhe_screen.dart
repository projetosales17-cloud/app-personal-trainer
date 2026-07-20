import 'package:flutter/material.dart';

import '../models/exercicio.dart';

class ExercicioDetalheScreen extends StatelessWidget {
  const ExercicioDetalheScreen({super.key, required this.exercicio});

  final Exercicio exercicio;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(exercicio.nome)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(exercicio.grupoMuscularPrincipal.label)),
              for (final secundario in exercicio.gruposMuscularesSecundarios)
                Chip(label: Text(secundario.label), visualDensity: VisualDensity.compact),
              Chip(label: Text(exercicio.nivel.label)),
              Chip(label: Text(exercicio.equipamento.label)),
              for (final objetivo in exercicio.objetivos) Chip(label: Text(objetivo.label)),
            ],
          ),
          const SizedBox(height: 24),
          Text('Como executar', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(exercicio.instrucoes, style: Theme.of(context).textTheme.bodyLarge),
          if (exercicio.urlVideo == null) ...[
            const SizedBox(height: 24),
            Text(
              'Vídeo de execução em breve.',
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
