import 'package:flutter/material.dart';

import '../models/registro_medidas.dart';
import '../services/progresso_repository.dart';

/// Campos de medida na ordem em que aparecem no formulário (de cima para
/// baixo no corpo).
class _CampoMedida {
  const _CampoMedida(this.chave, this.rotulo, this.ler, this.comValor);
  final String chave;
  final String rotulo;
  final double? Function(RegistroMedidas) ler;
  final RegistroMedidas Function(RegistroMedidas base, double? valor) comValor;
}

final _campos = <_CampoMedida>[
  _CampoMedida('pescoco', 'Cuello (cm)', (r) => r.pescocoCm,
      (r, v) => _copiar(r, pescoco: v)),
  _CampoMedida('torax', 'Tórax (cm)', (r) => r.toraxCm, (r, v) => _copiar(r, torax: v)),
  _CampoMedida('braco', 'Brazo (cm)', (r) => r.bracoCm, (r, v) => _copiar(r, braco: v)),
  _CampoMedida('antebraco', 'Antebrazo (cm)', (r) => r.antebracoCm,
      (r, v) => _copiar(r, antebraco: v)),
  _CampoMedida('cintura', 'Cintura (cm)', (r) => r.cinturaCm,
      (r, v) => _copiar(r, cintura: v)),
  _CampoMedida('quadril', 'Cadera (cm)', (r) => r.quadrilCm,
      (r, v) => _copiar(r, quadril: v)),
  _CampoMedida('coxa', 'Muslo (cm)', (r) => r.coxaCm, (r, v) => _copiar(r, coxa: v)),
  _CampoMedida('panturrilha', 'Pantorrilla (cm)', (r) => r.panturrilhaCm,
      (r, v) => _copiar(r, panturrilha: v)),
];

/// Como o modelo não tem `copyWith` (campos nulláveis não combinam com o
/// padrão `?? this.x`), reconstrói o registro trocando só um campo.
RegistroMedidas _copiar(
  RegistroMedidas r, {
  double? pescoco,
  double? torax,
  double? braco,
  double? antebraco,
  double? cintura,
  double? quadril,
  double? coxa,
  double? panturrilha,
}) => RegistroMedidas(
  id: r.id,
  data: r.data,
  pescocoCm: pescoco ?? r.pescocoCm,
  toraxCm: torax ?? r.toraxCm,
  bracoCm: braco ?? r.bracoCm,
  antebracoCm: antebraco ?? r.antebracoCm,
  cinturaCm: cintura ?? r.cinturaCm,
  quadrilCm: quadril ?? r.quadrilCm,
  coxaCm: coxa ?? r.coxaCm,
  panturrilhaCm: panturrilha ?? r.panturrilhaCm,
);

double? _parseCampo(TextEditingController c) {
  if (c.text.trim().isEmpty) return null;
  return double.tryParse(c.text.replaceAll(',', '.'));
}

class RegistroMedidasView extends StatefulWidget {
  RegistroMedidasView({super.key, ProgressoRepository? repositorio})
    : repositorio = repositorio ?? ProgressoRepository();

  final ProgressoRepository repositorio;

  @override
  State<RegistroMedidasView> createState() => _RegistroMedidasViewState();
}

class _RegistroMedidasViewState extends State<RegistroMedidasView> {
  late Future<List<RegistroMedidas>> _registrosFuture = widget.repositorio.listarMedidas();
  final _controladores = {for (final c in _campos) c.chave: TextEditingController()};

  @override
  void dispose() {
    for (final c in _controladores.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _recarregar() {
    setState(() {
      _registrosFuture = widget.repositorio.listarMedidas();
    });
  }

  RegistroMedidas _montar() {
    var registro = RegistroMedidas(data: DateTime.now());
    for (final campo in _campos) {
      registro = campo.comValor(registro, _parseCampo(_controladores[campo.chave]!));
    }
    return registro;
  }

  Future<void> _registrar() async {
    final registro = _montar();
    if (registro.vazio) return;

    await widget.repositorio.registrarMedidas(registro);
    for (final c in _controladores.values) {
      c.clear();
    }
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

  static String _resumo(RegistroMedidas registro) => [
    for (final (rotulo, valor) in registro.todas)
      if (valor != null) '$rotulo ${valor.toStringAsFixed(0)}cm',
  ].join(' · ');

  Widget _campo(String chave, String rotulo) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        key: Key('campo-$chave'),
        controller: _controladores[chave],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: rotulo),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          for (var i = 0; i < _campos.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  _campo(_campos[i].chave, _campos[i].rotulo),
                  if (i + 1 < _campos.length)
                    _campo(_campos[i + 1].chave, _campos[i + 1].rotulo)
                  else
                    const Spacer(),
                ],
              ),
            ),
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
  late final _controladores = {
    for (final campo in _campos)
      campo.chave: TextEditingController(
        text: campo.ler(widget.registro)?.toStringAsFixed(0) ?? '',
      ),
  };

  @override
  void dispose() {
    for (final c in _controladores.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar medidas'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final campo in _campos)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: TextField(
                  key: Key('editar-campo-${campo.chave}'),
                  controller: _controladores[campo.chave],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: campo.rotulo),
                ),
              ),
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
            var editado = RegistroMedidas(id: widget.registro.id, data: widget.registro.data);
            for (final campo in _campos) {
              editado = campo.comValor(editado, _parseCampo(_controladores[campo.chave]!));
            }
            if (editado.vazio) return;
            Navigator.of(context).pop(editado);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
