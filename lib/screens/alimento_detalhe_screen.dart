import 'package:flutter/material.dart';

import '../models/alimento.dart';

class AlimentoDetalheScreen extends StatelessWidget {
  const AlimentoDetalheScreen({
    super.key,
    required this.alimento,
    this.substitutos = const [],
  });

  final Alimento alimento;
  final List<Alimento> substitutos;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(alimento.nome)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(alimento.categoria.label)),
              Chip(label: Text('Porção: ${alimento.porcaoSugerida}')),
              if (alimento.contemLactose) const Chip(label: Text('Contém lactose')),
              if (alimento.contemGluten) const Chip(label: Text('Contém glúten')),
              if (alimento.vegano)
                const Chip(label: Text('Vegano'))
              else if (alimento.vegetariano)
                const Chip(label: Text('Vegetariano')),
            ],
          ),
          if (alimento.observacao != null) ...[
            const SizedBox(height: 16),
            Text(alimento.observacao!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 24),
          Text('Substituições nesta categoria', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (substitutos.isEmpty)
            const Text('Nenhuma substituição compatível encontrada nesta categoria.')
          else
            for (final substituto in substitutos)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(substituto.nome),
                subtitle: Text(substituto.porcaoSugerida),
              ),
        ],
      ),
    );
  }
}
