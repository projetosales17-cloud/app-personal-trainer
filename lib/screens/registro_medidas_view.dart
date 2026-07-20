import 'package:flutter/material.dart';

import '../models/registro_medidas.dart';
import '../services/progresso_repository.dart';

class RegistroMedidasView extends StatefulWidget {
  RegistroMedidasView({super.key, ProgressoRepository? repositorio})
    : repositorio = repositorio ?? ProgressoRepository();

  final ProgressoRepository repositorio;

  @override
  State<RegistroMedidasView> createState() => _RegistroMedidasViewState();
}

class _RegistroMedidasViewState extends State<RegistroMedidasView> {
  late Future<List<RegistroMedidas>> _registrosFuture = widget.repositorio.listarMedidas();
  final _controladorCintura = TextEditingController();
  final _controladorQuadril = TextEditingController();
  final _controladorBraco = TextEditingController();
  final _controladorCoxa = TextEditingController();

  @override
  void dispose() {
    _controladorCintura.dispose();
    _controladorQuadril.dispose();
    _controladorBraco.dispose();
    _controladorCoxa.dispose();
    super.dispose();
  }

  double? _parse(TextEditingController controlador) {
    if (controlador.text.trim().isEmpty) return null;
    return double.tryParse(controlador.text.replaceAll(',', '.'));
  }

  Future<void> _registrar() async {
    final registro = RegistroMedidas(
      data: DateTime.now(),
      cinturaCm: _parse(_controladorCintura),
      quadrilCm: _parse(_controladorQuadril),
      bracoCm: _parse(_controladorBraco),
      coxaCm: _parse(_controladorCoxa),
    );
    if (registro.vazio) return;

    await widget.repositorio.registrarMedidas(registro);
    _controladorCintura.clear();
    _controladorQuadril.clear();
    _controladorBraco.clear();
    _controladorCoxa.clear();
    setState(() {
      _registrosFuture = widget.repositorio.listarMedidas();
    });
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  String _resumo(RegistroMedidas registro) {
    final partes = [
      if (registro.cinturaCm != null) 'Cintura ${registro.cinturaCm!.toStringAsFixed(0)}cm',
      if (registro.quadrilCm != null) 'Quadril ${registro.quadrilCm!.toStringAsFixed(0)}cm',
      if (registro.bracoCm != null) 'Braço ${registro.bracoCm!.toStringAsFixed(0)}cm',
      if (registro.coxaCm != null) 'Coxa ${registro.coxaCm!.toStringAsFixed(0)}cm',
    ];
    return partes.join(' · ');
  }

  Widget _campo(Key chave, String rotulo, TextEditingController controlador) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: TextField(
          key: chave,
          controller: controlador,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: rotulo),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _campo(const Key('campo-cintura'), 'Cintura (cm)', _controladorCintura),
              _campo(const Key('campo-quadril'), 'Quadril (cm)', _controladorQuadril),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _campo(const Key('campo-braco'), 'Braço (cm)', _controladorBraco),
              _campo(const Key('campo-coxa'), 'Coxa (cm)', _controladorCoxa),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              key: const Key('botao-registrar-medidas'),
              onPressed: _registrar,
              child: const Text('Registrar'),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<RegistroMedidas>>(
              future: _registrosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                final registros = (snapshot.data ?? const <RegistroMedidas>[]).reversed.toList();
                if (registros.isEmpty) {
                  return const Center(
                    child: Text('Nenhum registro de medidas ainda. Adicione o primeiro acima.'),
                  );
                }

                return ListView.builder(
                  key: const Key('lista-registros-medidas'),
                  itemCount: registros.length,
                  itemBuilder: (context, indice) {
                    final registro = registros[indice];
                    return ListTile(
                      title: Text(_resumo(registro)),
                      subtitle: Text(_formatarData(registro.data)),
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
