import 'package:flutter/material.dart';

import '../models/orientacao.dart';
import '../services/biblioteca_orientacoes_repository.dart';
import 'orientacao_detalhe_screen.dart';

class OrientacoesScreen extends StatefulWidget {
  OrientacoesScreen({super.key, BibliotecaOrientacoesRepository? repositorio})
    : repositorio = repositorio ?? BibliotecaOrientacoesRepository();

  final BibliotecaOrientacoesRepository repositorio;

  @override
  State<OrientacoesScreen> createState() => _OrientacoesScreenState();
}

class _OrientacoesScreenState extends State<OrientacoesScreen> {
  TemaOrientacao? _filtro;
  final _controladorBusca = TextEditingController();
  String _busca = '';

  @override
  void dispose() {
    _controladorBusca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orientacoes = widget.repositorio.filtrar(tema: _filtro, busca: _busca);

    return Scaffold(
      appBar: AppBar(title: const Text('Orientações')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              key: const Key('campo-busca-orientacoes'),
              controller: _controladorBusca,
              decoration: const InputDecoration(
                labelText: 'Buscar por tema ou palavra-chave',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (valor) => setState(() => _busca = valor),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              key: const Key('filtro-temas'),
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
                for (final tema in TemaOrientacao.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(tema.label),
                      selected: _filtro == tema,
                      onSelected: (_) => setState(() => _filtro = tema),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: orientacoes.isEmpty
                ? const Center(child: Text('Nenhum conteúdo encontrado.'))
                : ListView.builder(
                    key: const Key('lista-orientacoes'),
                    itemCount: orientacoes.length,
                    itemBuilder: (context, indice) {
                      final orientacao = orientacoes[indice];
                      return ListTile(
                        title: Text(orientacao.titulo),
                        subtitle: Text(orientacao.tema.label),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => OrientacaoDetalheScreen(orientacao: orientacao),
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
