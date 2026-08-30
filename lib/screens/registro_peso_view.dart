import 'package:flutter/material.dart';

import '../models/registro_peso.dart';
import '../services/progresso_repository.dart';
import '../widgets/grafico_linha_simples.dart';

class RegistroPesoView extends StatefulWidget {
  RegistroPesoView({super.key, ProgressoRepository? repositorio})
    : repositorio = repositorio ?? ProgressoRepository();

  final ProgressoRepository repositorio;

  @override
  State<RegistroPesoView> createState() => _RegistroPesoViewState();
}

class _RegistroPesoViewState extends State<RegistroPesoView> {
  late Future<List<RegistroPeso>> _registrosFuture = widget.repositorio.listarPesos();
  final _controladorPeso = TextEditingController();

  @override
  void dispose() {
    _controladorPeso.dispose();
    super.dispose();
  }

  void _recarregar() {
    setState(() {
      _registrosFuture = widget.repositorio.listarPesos();
    });
  }

  Future<void> _registrar() async {
    final peso = double.tryParse(_controladorPeso.text.replaceAll(',', '.'));
    if (peso == null || peso <= 0) return;

    await widget.repositorio.registrarPeso(peso);
    _controladorPeso.clear();
    _recarregar();
  }

  Future<void> _editar(RegistroPeso registro) async {
    final novoPeso = await showDialog<double>(
      context: context,
      builder: (_) => _DialogoEditarPeso(pesoInicial: registro.pesoKg),
    );
    if (novoPeso == null) return;
    await widget.repositorio.atualizarPeso(registro.copyWith(pesoKg: novoPeso));
    _recarregar();
  }

  Future<void> _apagar(RegistroPeso registro) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar registro?'),
        content: Text(
          'El registro de ${registro.pesoKg.toStringAsFixed(1)} kg '
          '(${_formatarData(registro.data)}) se eliminará.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const Key('confirmar-apagar-peso'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await widget.repositorio.removerPeso(registro.id);
    _recarregar();
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('campo-peso'),
                  controller: _controladorPeso,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Peso actual (kg)'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                key: const Key('botao-registrar-peso'),
                onPressed: _registrar,
                child: const Text('Registrar'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<RegistroPeso>>(
              future: _registrosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                final ascendentes = snapshot.data ?? const <RegistroPeso>[];
                if (ascendentes.isEmpty) {
                  return const Center(
                    child: Text('Aún no hay registros de peso. Agrega el primero arriba.'),
                  );
                }

                final registros = ascendentes.reversed.toList();

                return Column(
                  children: [
                    if (ascendentes.length >= 2)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GraficoLinhaSimples(
                          valores: [for (final registro in ascendentes) registro.pesoKg],
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        key: const Key('lista-registros-peso'),
                        itemCount: registros.length,
                        itemBuilder: (context, indice) {
                          final registro = registros[indice];
                          return ListTile(
                            title: Text('${registro.pesoKg.toStringAsFixed(1)} kg'),
                            subtitle: Text(_formatarData(registro.data)),
                            trailing: PopupMenuButton<String>(
                              key: Key('menu-peso-${registro.id}'),
                              onSelected: (opcao) {
                                if (opcao == 'editar') _editar(registro);
                                if (opcao == 'apagar') _apagar(registro);
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(value: 'editar', child: Text('Editar')),
                                PopupMenuItem(value: 'apagar', child: Text('Borrar')),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogoEditarPeso extends StatefulWidget {
  const _DialogoEditarPeso({required this.pesoInicial});

  final double pesoInicial;

  @override
  State<_DialogoEditarPeso> createState() => _DialogoEditarPesoState();
}

class _DialogoEditarPesoState extends State<_DialogoEditarPeso> {
  late final _controlador = TextEditingController(
    text: widget.pesoInicial.toStringAsFixed(1),
  );

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar peso'),
      content: TextField(
        key: const Key('editar-campo-peso'),
        controller: _controlador,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(labelText: 'Peso (kg)'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const Key('editar-salvar-peso'),
          onPressed: () {
            final peso = double.tryParse(_controlador.text.replaceAll(',', '.'));
            if (peso == null || peso <= 0) return;
            Navigator.of(context).pop(peso);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
