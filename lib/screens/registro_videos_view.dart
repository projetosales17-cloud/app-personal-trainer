import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/registro_video.dart';
import '../services/progresso_repository.dart';
import 'video_detalhe_screen.dart';

typedef SelecionarVideo = Future<String?> Function(ImageSource fonte);

Future<String?> _selecionarVideoPadrao(ImageSource fonte) async {
  final arquivo = await ImagePicker().pickVideo(
    source: fonte,
    maxDuration: const Duration(seconds: 60),
  );
  return arquivo?.path;
}

class RegistroVideosView extends StatefulWidget {
  RegistroVideosView({
    super.key,
    ProgressoRepository? repositorio,
    SelecionarVideo? selecionarVideo,
  }) : repositorio = repositorio ?? ProgressoRepository(),
       selecionarVideo = selecionarVideo ?? _selecionarVideoPadrao;

  final ProgressoRepository repositorio;
  final SelecionarVideo selecionarVideo;

  @override
  State<RegistroVideosView> createState() => _RegistroVideosViewState();
}

class _RegistroVideosViewState extends State<RegistroVideosView> {
  late Future<List<RegistroVideo>> _videosFuture = widget.repositorio.listarVideos();

  Future<void> _adicionar(ImageSource fonte) async {
    final caminho = await widget.selecionarVideo(fonte);
    if (caminho == null) return;

    await widget.repositorio.registrarVideo(File(caminho));
    setState(() {
      _videosFuture = widget.repositorio.listarVideos();
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
                child: OutlinedButton.icon(
                  key: const Key('botao-camera-video'),
                  onPressed: () => _adicionar(ImageSource.camera),
                  icon: const Icon(Icons.videocam_outlined),
                  label: const Text('Câmera'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('botao-galeria-video'),
                  onPressed: () => _adicionar(ImageSource.gallery),
                  icon: const Icon(Icons.video_library_outlined),
                  label: const Text('Galeria'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<RegistroVideo>>(
              future: _videosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                final videos = (snapshot.data ?? const <RegistroVideo>[]).reversed.toList();
                if (videos.isEmpty) {
                  return const Center(
                    child: Text('Nenhum vídeo ainda. Adicione o primeiro acima.'),
                  );
                }

                return ListView.builder(
                  key: const Key('lista-videos'),
                  itemCount: videos.length,
                  itemBuilder: (context, indice) {
                    final video = videos[indice];
                    return ListTile(
                      leading: const Icon(Icons.play_circle_outline),
                      title: Text(_formatarData(video.data)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => VideoDetalheScreen(video: video)),
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
