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

  void _recarregar() {
    setState(() {
      _registrosFuture = widget.repositorio.listarMedidas();
    });
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
    _recarregar();
  }

  Future<void> _editar(RegistroMedidas registro) async {
    final editado = await showDialog<RegistroMedidas>(
      context: context,
      builder: (_) => _DialogoEditarMedidas(registro: registro),
    );
    if (editado == null) return;
    await widget.repositorio.atualizarMedidas(editado);
    _recarregar();
  }

  Future<void> _apagar(RegistroMedidas registro) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar registro?'),
        content: Text(
          'El registro de medidas del ${_formatarData(registro.data)} se eliminará.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const Key('confirmar-apagar-medidas'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await widget.repositorio.removerMedidas(registro.id);
    _recarregar();
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  String _resumo(RegistroMedidas registro) {
    final partes = [
      if (registro.cinturaCm != null) 'Cintura ${registro.cinturaCm!.toStringAsFixed(0)}cm',
      if (registro.quadrilCm != null) 'Cadera ${registro.quadrilCm!.toStringAsFixed(0)}cm',
      if (registro.bracoCm != null) 'Brazo ${registro.bracoCm!.toStringAsFixed(0)}cm',
      if (registro.coxaCm != null) 'Muslo ${registro.coxaCm!.toStringAsFixed(0)}cm',
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
              _campo(const Key('campo-quadril'), 'Cadera (cm)', _controladorQuadril),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _campo(const Key('campo-braco'), 'Brazo (cm)', _controladorBraco),
              _campo(const Key('campo-coxa'), 'Muslo (cm)', _controladorCoxa),
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
                    child: Text('Aún no hay registros de medidas. Agrega el primero arriba.'),
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
                      trailing: PopupMenuButton<String>(
                        key: Key('menu-medidas-${registro.id}'),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogoEditarMedidas extends StatefulWidget {
  const _DialogoEditarMedidas({required this.registro});

  final RegistroMedidas registro;

  @override
  State<_DialogoEditarMedidas> createState() => _DialogoEditarMedidasState();
}

class _DialogoEditarMedidasState extends State<_DialogoEditarMedidas> {
  late final _cintura = _controlador(widget.registro.cinturaCm);
  late final _quadril = _controlador(widget.registro.quadrilCm);
  late final _braco = _controlador(widget.registro.bracoCm);
  late final _coxa = _controlador(widget.registro.coxaCm);

  TextEditingController _controlador(double? valor) => TextEditingController(
    text: valor == null ? '' : valor.toStringAsFixed(0),
  );

  double? _parse(TextEditingController c) {
    if (c.text.trim().isEmpty) return null;
    return double.tryParse(c.text.replaceAll(',', '.'));
  }

  @override
  void dispose() {
    _cintura.dispose();
    _quadril.dispose();
    _braco.dispose();
    _coxa.dispose();
    super.dispose();
  }

  Widget _campo(Key chave, String rotulo, TextEditingController c) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: TextField(
      key: chave,
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: rotulo),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar medidas'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _campo(const Key('editar-campo-cintura'), 'Cintura (cm)', _cintura),
            _campo(const Key('editar-campo-quadril'), 'Cadera (cm)', _quadril),
            _campo(const Key('editar-campo-braco'), 'Brazo (cm)', _braco),
            _campo(const Key('editar-campo-coxa'), 'Muslo (cm)', _coxa),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const Key('editar-salvar-medidas'),
          onPressed: () {
            final editado = RegistroMedidas(
              id: widget.registro.id,
              data: widget.registro.data,
              cinturaCm: _parse(_cintura),
              quadrilCm: _parse(_quadril),
              bracoCm: _parse(_braco),
              coxaCm: _parse(_coxa),
            );
            if (editado.vazio) return;
            Navigator.of(context).pop(editado);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
