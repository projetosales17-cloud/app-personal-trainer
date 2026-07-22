import 'package:flutter/material.dart';

import '../models/publicacao_comunidade.dart';
import '../services/biblioteca_comunidade_repository.dart';

/// Aba Comunidade: feed de leitura com depoimentos, dicas e conquistas
/// curados (ver aviso em PublicacaoComunidade). Não há postar, comentar ou
/// curtir nesta v1.
class ComunidadeScreen extends StatefulWidget {
  ComunidadeScreen({super.key, BibliotecaComunidadeRepository? repositorio})
    : repositorio = repositorio ?? BibliotecaComunidadeRepository();

  final BibliotecaComunidadeRepository repositorio;

  @override
  State<ComunidadeScreen> createState() => _ComunidadeScreenState();
}

class _ComunidadeScreenState extends State<ComunidadeScreen> {
  TipoPublicacaoComunidade? _filtro;

  @override
  Widget build(BuildContext context) {
    final publicacoes = widget.repositorio.filtrar(tipo: _filtro);

    return Scaffold(
      appBar: AppBar(title: const Text('Comunidade')),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              key: const Key('filtro-tipos-comunidade'),
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
                for (final tipo in TipoPublicacaoComunidade.values)
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
            child: publicacoes.isEmpty
                ? const Center(child: Text('Nenhuma publicação encontrada.'))
                : ListView.builder(
                    key: const Key('lista-comunidade'),
                    padding: const EdgeInsets.all(16),
                    itemCount: publicacoes.length,
                    itemBuilder: (context, indice) {
                      final publicacao = publicacoes[indice];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      publicacao.autora,
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                  ),
                                  Chip(
                                    label: Text(publicacao.tipo.label),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(publicacao.texto),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
