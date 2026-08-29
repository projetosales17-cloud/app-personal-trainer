import 'package:flutter/material.dart';

import '../models/registro_foto.dart';
import '../services/progresso_repository.dart';

class FotoDetalheScreen extends StatelessWidget {
  FotoDetalheScreen({super.key, required this.foto, ProgressoRepository? repositorio})
    : repositorio = repositorio ?? ProgressoRepository();

  final RegistroFoto foto;
  final ProgressoRepository repositorio;

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  Future<void> _remover(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar foto?'),
        content: const Text('Essa foto de progresso será removida de todos os aparelhos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (confirmar != true || !context.mounted) return;
    await repositorio.removerFoto(foto.id);
    if (context.mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_formatarData(foto.data)),
        actions: [
          IconButton(
            key: const Key('botao-apagar-foto'),
            tooltip: 'Apagar foto',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _remover(context),
          ),
        ],
      ),
      body: Center(child: Image.memory(foto.bytes)),
    );
  }
}
