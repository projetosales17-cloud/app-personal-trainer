import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Reprodução do vídeo curto de uma orientação (conteúdo pré-gravado,
/// hospedado externamente — ver Orientacao.urlVideo). Sem teste de widget
/// automatizado: assim como VideoDetalheScreen, depende de inicialização
/// real de platform channel/rede, indisponível no ambiente de teste.
class OrientacaoVideoScreen extends StatefulWidget {
  const OrientacaoVideoScreen({super.key, required this.titulo, required this.urlVideo});

  final String titulo;
  final String urlVideo;

  @override
  State<OrientacaoVideoScreen> createState() => _OrientacaoVideoScreenState();
}

class _OrientacaoVideoScreenState extends State<OrientacaoVideoScreen> {
  late final VideoPlayerController _controller;
  late final Future<void> _inicializacao;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.urlVideo));
    _inicializacao = _controller.initialize();
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
