import 'package:flutter/material.dart';

import '../models/registro_diario.dart';
import '../services/diario_alimentar_repository.dart';

const _refeicoes = ['Café da manhã', 'Almoço', 'Lanche da tarde', 'Jantar', 'Ceia'];

class DiarioAlimentarView extends StatefulWidget {
  DiarioAlimentarView({super.key, DiarioAlimentarRepository? repositorio})
    : repositorio = repositorio ?? DiarioAlimentarRepository();

  final DiarioAlimentarRepository repositorio;

  @override
  State<DiarioAlimentarView> createState() => _DiarioAlimentarViewState();
}

class _DiarioAlimentarViewState extends State<DiarioAlimentarView> {
  late Future<List<RegistroDiario>> _registrosFuture = widget.repositorio.listar();
  final _controladorDescricao = TextEditingController();
  String _refeicaoSelecionada = _refeicoes.first;

  @override
  void dispose() {
    _controladorDescricao.dispose();
    super.dispose();
  }

  void _recarregar() {
    setState(() {
      _registrosFuture = widget.repositorio.listar();
    });
  }

  Future<void> _registrar() async {
    final descricao = _controladorDescricao.text.trim();
    if (descricao.isEmpty) return;

    await widget.repositorio.registrar(_refeicaoSelecionada, descricao);
    _controladorDescricao.clear();
    _recarregar();
  }

  Future<void> _editar(RegistroDiario registro) async {
    final editado = await showDialog<RegistroDiario>(
      context: context,
      builder: (_) => _DialogoEditarRegistro(registro: registro),
    );
    if (editado == null) return;
    await widget.repositorio.atualizar(editado);
    _recarregar();
  }

  Future<void> _apagar(RegistroDiario registro) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar registro?'),
        content: Text('"${registro.descricao}" será removido do diário.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const Key('confirmar-apagar-diario'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await widget.repositorio.remover(registro.id);
    _recarregar();
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');
    return '$dia/$mes $hora:$minuto';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              DropdownButton<String>(
                key: const Key('campo-refeicao'),
                value: _refeicaoSelecionada,
                items: [
                  for (final refeicao in _refeicoes)
                    DropdownMenuItem(value: refeicao, child: Text(refeicao)),
                ],
                onChanged: (valor) {
                  if (valor != null) setState(() => _refeicaoSelecionada = valor);
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  key: const Key('campo-descricao'),
                  controller: _controladorDescricao,
                  decoration: const InputDecoration(labelText: 'O que você comeu?'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                key: const Key('botao-registrar-diario'),
                onPressed: _registrar,
                child: const Text('Registrar'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<RegistroDiario>>(
              future: _registrosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                final registros = (snapshot.data ?? const <RegistroDiario>[]).reversed.toList();
                if (registros.isEmpty) {
                  return const Center(
                    child: Text('Nenhum registro no diário ainda. Adicione o primeiro acima.'),
                  );
                }

                return ListView.builder(
                  key: const Key('lista-registros-diario'),
                  itemCount: registros.length,
                  itemBuilder: (context, indice) {
                    final registro = registros[indice];
                    return ListTile(
                      title: Text(registro.descricao),
                      subtitle: Text('${registro.refeicao} · ${_formatarData(registro.data)}'),
                      trailing: PopupMenuButton<String>(
                        key: Key('menu-registro-${registro.id}'),
                        onSelected: (opcao) {
                          if (opcao == 'editar') _editar(registro);
                          if (opcao == 'apagar') _apagar(registro);
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'editar', child: Text('Editar')),
                          PopupMenuItem(value: 'apagar', child: Text('Apagar')),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogoEditarRegistro extends StatefulWidget {
  const _DialogoEditarRegistro({required this.registro});

  final RegistroDiario registro;

  @override
  State<_DialogoEditarRegistro> createState() => _DialogoEditarRegistroState();
}

class _DialogoEditarRegistroState extends State<_DialogoEditarRegistro> {
  late final _controlador = TextEditingController(text: widget.registro.descricao);
  late String _refeicao = _refeicoes.contains(widget.registro.refeicao)
      ? widget.registro.refeicao
      : _refeicoes.first;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar registro'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
            key: const Key('editar-campo-refeicao'),
            isExpanded: true,
            value: _refeicao,
            items: [
              for (final refeicao in _refeicoes)
                DropdownMenuItem(value: refeicao, child: Text(refeicao)),
            ],
            onChanged: (valor) {
              if (valor != null) setState(() => _refeicao = valor);
            },
          ),
          TextField(
            key: const Key('editar-campo-descricao'),
            controller: _controlador,
            decoration: const InputDecoration(labelText: 'O que você comeu?'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const Key('editar-salvar-diario'),
          onPressed: () {
            final descricao = _controlador.text.trim();
            if (descricao.isEmpty) return;
            Navigator.of(context).pop(
              widget.registro.copyWith(refeicao: _refeicao, descricao: descricao),
            );
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
