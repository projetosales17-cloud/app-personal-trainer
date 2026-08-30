import 'package:flutter/material.dart';

import '../models/registro_foto.dart';
import '../services/progresso_repository.dart';

class FotoDetalheScreen extends StatefulWidget {
  FotoDetalheScreen({super.key, required this.foto, ProgressoRepository? repositorio})
    : repositorio = repositorio ?? ProgressoRepository();

  final RegistroFoto foto;
  final ProgressoRepository repositorio;

  @override
  State<FotoDetalheScreen> createState() => _FotoDetalheScreenState();
}

class _FotoDetalheScreenState extends State<FotoDetalheScreen> {
  late PoseFoto _pose = widget.foto.pose;
  bool _alterada = false;

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  Future<void> _trocarAngulo() async {
    final nova = await showDialog<PoseFoto>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Ángulo de la foto'),
        children: [
          for (final pose in PoseFoto.values)
            ListTile(
              key: Key('opcao-pose-${pose.name}'),
              title: Text(pose.label),
              trailing: pose == _pose ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(context).pop(pose),
            ),
        ],
      ),
    );
    if (nova == null || nova == _pose || !mounted) return;
    await widget.repositorio.atualizarPoseFoto(widget.foto.id, nova);
    if (!mounted) return;
    setState(() {
      _pose = nova;
      _alterada = true;
    });
  }

  Future<void> _remover() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar foto?'),
        content: const Text('Esta foto de progreso se eliminará de todos los dispositivos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    await widget.repositorio.removerFoto(widget.foto.id);
    if (mounted) Navigator.of(context).pop('removida');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_alterada,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop('alterada');
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${_pose.label} · ${_formatarData(widget.foto.data)}'),
          actions: [
            IconButton(
              key: const Key('botao-trocar-angulo-foto'),
              tooltip: 'Cambiar ángulo',
              icon: const Icon(Icons.rotate_90_degrees_ccw_outlined),
              onPressed: _trocarAngulo,
            ),
            IconButton(
              key: const Key('botao-apagar-foto'),
              tooltip: 'Borrar foto',
              icon: const Icon(Icons.delete_outline),
              onPressed: _remover,
            ),
          ],
        ),
        body: Center(child: Image.memory(widget.foto.bytes)),
      ),
    );
  }
}
