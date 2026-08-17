import 'package:flutter/material.dart';

import '../models/receita.dart';

class ReceitaDetalheScreen extends StatelessWidget {
  const ReceitaDetalheScreen({super.key, required this.receita});

  final Receita receita;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(receita.titulo)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(receita.tipoRefeicao.label)),
              Chip(label: Text('${receita.tempoPreparoMinutos} min')),
              Chip(label: Text('${receita.porcoes} porción(es)')),
              if (receita.contemLactose) const Chip(label: Text('Contiene lactosa')),
              if (receita.contemGluten) const Chip(label: Text('Contiene gluten')),
              if (receita.vegano)
                const Chip(label: Text('Vegano'))
              else if (receita.vegetariano)
                const Chip(label: Text('Vegetariano')),
            ],
          ),
          const SizedBox(height: 24),
          Text('Ingredientes', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final ingrediente in receita.ingredientes)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $ingrediente'),
            ),
          const SizedBox(height: 24),
          Text('Modo de preparación', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(receita.modoPreparo, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
