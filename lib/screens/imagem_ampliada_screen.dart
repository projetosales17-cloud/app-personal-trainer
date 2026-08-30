import 'package:flutter/material.dart';

/// Abre uma imagem em tela cheia com zoom (pinça) e arrastar — para quem
/// precisa ampliar para enxergar bem os detalhes do exercício ou da foto.
class ImagemAmpliadaScreen extends StatelessWidget {
  const ImagemAmpliadaScreen({super.key, required this.imagem, this.titulo});

  /// O widget de imagem a ampliar (`Image.asset`, `Image.memory`,
  /// `SvgPicture`, etc.).
  final Widget imagem;
  final String? titulo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: titulo == null ? null : Text(titulo!),
        leading: IconButton(
          key: const Key('fechar-imagem-ampliada'),
          icon: const Icon(Icons.close),
          tooltip: 'Cerrar',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: InteractiveViewer(
        key: const Key('imagem-ampliada'),
        minScale: 1,
        maxScale: 6,
        child: Center(child: imagem),
      ),
    );
  }
}
