import 'package:flutter_video_thumbnail_plus/flutter_video_thumbnail_plus.dart';

typedef GerarMiniaturaVideo = Future<String?> Function(String caminhoVideo, String pastaDestino);

/// Gera uma miniatura (thumbnail) JPEG a partir do vídeo, salva na pasta
/// informada. `flutter_video_thumbnail_plus` tem implementação nativa para
/// Android, iOS, Windows e macOS.
Future<String?> gerarMiniaturaVideoPadrao(String caminhoVideo, String pastaDestino) {
  return FlutterVideoThumbnailPlus.thumbnailFile(
    video: caminhoVideo,
    thumbnailPath: pastaDestino,
    imageFormat: ImageFormat.jpeg,
    quality: 75,
  );
}
