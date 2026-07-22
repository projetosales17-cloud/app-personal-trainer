import 'package:flutter/material.dart';

import '../models/suplemento.dart';
import '../services/biblioteca_suplementos_repository.dart';
import 'suplemento_detalhe_screen.dart';

class SuplementosView extends StatefulWidget {
  SuplementosView({super.key, BibliotecaSuplementosRepository? repositorio})
    : repositorio = repositorio ?? BibliotecaSuplementosRepository();

  final BibliotecaSuplementosRepository repositorio;

  @override
  State<SuplementosView> createState() => _SuplementosViewState();
}

class _SuplementosViewState extends State<SuplementosView> {
  TipoSuplemento? _filtro;

  @override
  Widget build(BuildContext context) {
    final suplementos = widget.repositorio.filtrar(tipo: _filtro);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Conteúdo educativo geral, sem dosagem ou recomendação '
            'individualizada. Consulte um(a) nutricionista ou médico antes de '
            'usar qualquer suplemento.',
            style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
          ),
        ),
        SizedBox(
          height: 56,
          child: ListView(
            key: const Key('filtro-tipos-suplementos'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: const Text('Todos'),
                  selected: _filtro == null,
                  onSelected: (_) => setState(() => _filtro = null),
                ),
              ),
              for (final tipo in TipoSuplemento.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(tipo.label),
                    selected: _filtro == tipo,
                    onSelected: (_) => setState(() => _filtro = tipo),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            key: const Key('lista-suplementos'),
            itemCount: suplementos.length,
            itemBuilder: (context, indice) {
              final suplemento = suplementos[indice];
              return ListTile(
                title: Text(suplemento.nome),
                subtitle: Text(suplemento.tipo.label),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SuplementoDetalheScreen(suplemento: suplemento),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
