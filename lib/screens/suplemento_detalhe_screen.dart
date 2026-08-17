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
          if (suplemento.dosagemGenerica != null) ...[
            const SizedBox(height: 24),
            Text('Rango general de uso', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(suplemento.dosagemGenerica!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Contenido educativo general — el rango de uso anterior es una '
              'referencia amplia, no una recomendación individualizada. Consulta '
              'a un(a) nutricionista o médico antes de usar, especialmente si te '
              'hiciste una cirugía bariátrica o tienes alguna condición de salud.',
              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
