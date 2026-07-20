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

  Future<void> _registrar() async {
    final peso = double.tryParse(_controladorPeso.text.replaceAll(',', '.'));
    if (peso == null || peso <= 0) return;

    await widget.repositorio.registrarPeso(peso);
    _controladorPeso.clear();
    setState(() {
      _registrosFuture = widget.repositorio.listarPesos();
    });
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
                  decoration: const InputDecoration(labelText: 'Peso atual (kg)'),
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
                    child: Text('Nenhum registro de peso ainda. Adicione o primeiro acima.'),
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
