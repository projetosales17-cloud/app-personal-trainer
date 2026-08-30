import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/registro_video.dart';
import '../services/progresso_repository.dart';

class VideoDetalheScreen extends StatefulWidget {
  VideoDetalheScreen({super.key, required this.video, ProgressoRepository? repositorio})
    : repositorio = repositorio ?? ProgressoRepository();

  final RegistroVideo video;
  final ProgressoRepository repositorio;

  @override
  State<VideoDetalheScreen> createState() => _VideoDetalheScreenState();
}

class _VideoDetalheScreenState extends State<VideoDetalheScreen> {
  late final VideoPlayerController _controller;
  late final Future<void> _inicializacao;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.video.caminhoArquivo));
    _inicializacao = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _remover() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar video?'),
        content: const Text('Este video de progreso se borrará del dispositivo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const Key('confirmar-apagar-video'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    await widget.repositorio.removerVideo(widget.video.id);
    if (mounted) Navigator.of(context).pop(true);
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_formatarData(widget.video.data)),
        actions: [
          IconButton(
            key: const Key('botao-apagar-video'),
            tooltip: 'Borrar video',
            icon: const Icon(Icons.delete_outline),
            onPressed: _remover,
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<void>(
          future: _inicializacao,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator();
            }

            return AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller),
                  IconButton(
                    key: const Key('botao-play-pause'),
                    iconSize: 64,
                    color: Colors.white,
                    icon: Icon(
                      _controller.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
                    ),
                    onPressed: () {
                      setState(() {
                        _controller.value.isPlaying ? _controller.pause() : _controller.play();
                      });
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
