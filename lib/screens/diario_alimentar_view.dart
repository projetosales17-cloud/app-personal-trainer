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

  Future<void> _registrar() async {
    final descricao = _controladorDescricao.text.trim();
    if (descricao.isEmpty) return;

    await widget.repositorio.registrar(_refeicaoSelecionada, descricao);
    _controladorDescricao.clear();
    setState(() {
      _registrosFuture = widget.repositorio.listar();
    });
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
