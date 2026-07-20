import 'package:flutter/material.dart';

import '../models/alimento.dart';
import '../services/anamnese_repository.dart';
import '../services/biblioteca_alimentos_repository.dart';
import 'alimento_detalhe_screen.dart';

class BibliotecaAlimentosView extends StatefulWidget {
  BibliotecaAlimentosView({
    super.key,
    BibliotecaAlimentosRepository? repositorio,
    AnamneseRepository? anamneseRepositorio,
  }) : repositorio = repositorio ?? BibliotecaAlimentosRepository(),
       anamneseRepositorio = anamneseRepositorio ?? AnamneseRepository();

  final BibliotecaAlimentosRepository repositorio;
  final AnamneseRepository anamneseRepositorio;

  @override
  State<BibliotecaAlimentosView> createState() => _BibliotecaAlimentosViewState();
}

class _BibliotecaAlimentosViewState extends State<BibliotecaAlimentosView> {
  CategoriaAlimento? _filtro;
  late final Future<List<String>> _restricoesFuture = _carregarRestricoes();

  Future<List<String>> _carregarRestricoes() async {
    final anamnese = await widget.anamneseRepositorio.carregar();
    return anamnese?.restricoesAlimentares ?? const [];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _restricoesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final restricoes = snapshot.data ?? const [];
        final alimentos = widget.repositorio.filtrar(
          categoria: _filtro,
          restricoesUsuaria: restricoes,
        );

        return Column(
          children: [
            SizedBox(
              height: 56,
              child: ListView(
                key: const Key('filtro-categorias'),
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
                  for (final categoria in CategoriaAlimento.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(categoria.label),
                        selected: _filtro == categoria,
                        onSelected: (_) => setState(() => _filtro = categoria),
                      ),
                    ),
                ],
              ),
            ),
            if (restricoes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Filtrado para suas restrições: ${restricoes.join(", ")}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                key: const Key('lista-alimentos'),
                itemCount: alimentos.length,
                itemBuilder: (context, indice) {
                  final alimento = alimentos[indice];
                  return ListTile(
                    title: Text(alimento.nome),
                    subtitle: Text('${alimento.categoria.label} · ${alimento.porcaoSugerida}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AlimentoDetalheScreen(
                          alimento: alimento,
                          substitutos: widget.repositorio.substitutos(
                            alimento,
                            restricoesUsuaria: restricoes,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
