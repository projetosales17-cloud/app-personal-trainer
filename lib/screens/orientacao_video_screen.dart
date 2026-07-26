import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Reprodução do vídeo curto de fundo de uma orientação (asset local, em
/// loop, sem áudio — ver Orientacao.caminhoVideo) com o título e o corpo do
/// texto sobrepostos nativamente pelo Flutter. Sem teste de widget
/// automatizado: assim como VideoDetalheScreen, depende de inicialização
/// real de platform channel, indisponível no ambiente de teste.
class OrientacaoVideoScreen extends StatefulWidget {
  const OrientacaoVideoScreen({
    super.key,
    required this.titulo,
    required this.corpo,
    required this.caminhoVideo,
  });

  final String titulo;
  final String corpo;
  final String caminhoVideo;

  @override
  State<OrientacaoVideoScreen> createState() => _OrientacaoVideoScreenState();
}

class _OrientacaoVideoScreenState extends State<OrientacaoVideoScreen> {
  late final VideoPlayerController _controller;
  late final Future<void> _inicializacao;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.caminhoVideo);
    _inicializacao = _controller.initialize().then((_) {
      _controller
        ..setLooping(true)
        ..setVolume(0)
        ..play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
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
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black.withValues(alpha: 0), Colors.black.withValues(alpha: 0.85)],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.titulo,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.corpo,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('botao-play-pause-orientacao'),
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
