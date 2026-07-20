import 'package:flutter/material.dart';

import '../models/receita.dart';
import '../services/anamnese_repository.dart';
import '../services/biblioteca_receitas_repository.dart';
import 'receita_detalhe_screen.dart';

class ReceitasView extends StatefulWidget {
  ReceitasView({
    super.key,
    BibliotecaReceitasRepository? repositorio,
    AnamneseRepository? anamneseRepositorio,
  }) : repositorio = repositorio ?? BibliotecaReceitasRepository(),
       anamneseRepositorio = anamneseRepositorio ?? AnamneseRepository();

  final BibliotecaReceitasRepository repositorio;
  final AnamneseRepository anamneseRepositorio;

  @override
  State<ReceitasView> createState() => _ReceitasViewState();
}

class _ReceitasViewState extends State<ReceitasView> {
  TipoRefeicao? _filtro;
  final _controladorBusca = TextEditingController();
  String _busca = '';
  late final Future<List<String>> _restricoesFuture = _carregarRestricoes();

  Future<List<String>> _carregarRestricoes() async {
    final anamnese = await widget.anamneseRepositorio.carregar();
    return anamnese?.restricoesAlimentares ?? const [];
  }

  @override
  void dispose() {
    _controladorBusca.dispose();
    super.dispose();
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
        final receitas = widget.repositorio.filtrar(
          tipoRefeicao: _filtro,
          restricoesUsuaria: restricoes,
          busca: _busca,
        );

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                key: const Key('campo-busca-receitas'),
                controller: _controladorBusca,
                decoration: const InputDecoration(
                  labelText: 'Buscar receita',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (valor) => setState(() => _busca = valor),
              ),
            ),
            SizedBox(
              height: 56,
              child: ListView(
                key: const Key('filtro-tipo-refeicao'),
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
                  for (final tipo in TipoRefeicao.values)
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
              child: receitas.isEmpty
                  ? const Center(child: Text('Nenhuma receita encontrada.'))
                  : ListView.builder(
                      key: const Key('lista-receitas'),
                      itemCount: receitas.length,
                      itemBuilder: (context, indice) {
                        final receita = receitas[indice];
                        return ListTile(
                          title: Text(receita.titulo),
                          subtitle: Text(
                            '${receita.tipoRefeicao.label} · ${receita.tempoPreparoMinutos} min',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ReceitaDetalheScreen(receita: receita),
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
