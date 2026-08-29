import 'package:flutter/material.dart';

import '../models/registro_foto.dart';
import '../services/progresso_repository.dart';
import 'foto_detalhe_screen.dart';

/// Comparação antes/depois por ângulo: pra cada ângulo com 2+ fotos, mostra
/// a mais antiga e a mais recente lado a lado, mais a linha do tempo desse
/// ângulo. Comparar frente com frente (e não frente com costas).
class AntesDepoisView extends StatefulWidget {
  AntesDepoisView({super.key, ProgressoRepository? repositorio})
    : repositorio = repositorio ?? ProgressoRepository();

  final ProgressoRepository repositorio;

  @override
  State<AntesDepoisView> createState() => _AntesDepoisViewState();
}

class _AntesDepoisViewState extends State<AntesDepoisView> {
  List<RegistroFoto>? _fotos;

  @override
  void initState() {
    super.initState();
    widget.repositorio.listarFotos().then((fotos) {
      if (mounted) setState(() => _fotos = fotos);
    });
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  Future<void> _abrir(RegistroFoto foto) async {
    final removida = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FotoDetalheScreen(foto: foto, repositorio: widget.repositorio),
      ),
    );
    if (removida == true && mounted) {
      setState(() => _fotos?.removeWhere((f) => f.id == foto.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final fotos = _fotos;
    if (fotos == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final porPose = <PoseFoto, List<RegistroFoto>>{
      for (final pose in PoseFoto.values)
        if (fotos.where((f) => f.pose == pose).length >= 2)
          pose: fotos.where((f) => f.pose == pose).toList(),
    };

    if (porPose.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Registra al menos dos fotos del mismo ángulo en la pestaña Fotos '
            'para ver la comparación antes/después.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final entrada in porPose.entries) ...[
            _SecaoPose(
              pose: entrada.key,
              fotos: entrada.value,
              formatarData: _formatarData,
              aoTocar: _abrir,
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

class _SecaoPose extends StatelessWidget {
  const _SecaoPose({
    required this.pose,
    required this.fotos,
    required this.formatarData,
    required this.aoTocar,
  });

  final PoseFoto pose;
  final List<RegistroFoto> fotos;
  final String Function(DateTime) formatarData;
  final void Function(RegistroFoto) aoTocar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(pose.label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _CartaoFoto(titulo: 'Antes', foto: fotos.first, formatarData: formatarData),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _CartaoFoto(titulo: 'Después', foto: fotos.last, formatarData: formatarData),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.separated(
            key: Key('linha-do-tempo-${pose.name}'),
            scrollDirection: Axis.horizontal,
            itemCount: fotos.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, indice) {
              final foto = fotos[indice];
              return GestureDetector(
                onTap: () => aoTocar(foto),
                child: SizedBox(
                  width: 80,
                  child: Column(
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: Image.memory(
                            foto.bytes,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatarData(foto.data),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CartaoFoto extends StatelessWidget {
  const _CartaoFoto({
    required this.titulo,
    required this.foto,
    required this.formatarData,
  });

  final String titulo;
  final RegistroFoto foto;
  final String Function(DateTime) formatarData;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(titulo, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 3 / 4,
          child: Image.memory(foto.bytes, fit: BoxFit.cover, gaplessPlayback: true),
        ),
        const SizedBox(height: 4),
        Text(
          formatarData(foto.data),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
