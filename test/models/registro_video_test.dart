import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/models/registro_video.dart';

void main() {
  test('toJson/fromJson preservam data e caminho do arquivo', () {
    final registro = RegistroVideo(
      data: DateTime(2026, 3, 15),
      caminhoArquivo: '/dados/app/videos_progresso/123.mp4',
    );

    final json = registro.toJson();
    final reconstruido = RegistroVideo.fromJson(json);

    expect(reconstruido.data, DateTime(2026, 3, 15));
    expect(reconstruido.caminhoArquivo, '/dados/app/videos_progresso/123.mp4');
    expect(reconstruido.caminhoMiniatura, isNull);
  });

  test('toJson/fromJson preservam o caminho da miniatura quando presente', () {
    final registro = RegistroVideo(
      data: DateTime(2026, 3, 15),
      caminhoArquivo: '/dados/app/videos_progresso/123.mp4',
      caminhoMiniatura: '/dados/app/miniaturas_videos_progresso/123.jpg',
    );

    final reconstruido = RegistroVideo.fromJson(registro.toJson());

    expect(reconstruido.caminhoMiniatura, '/dados/app/miniaturas_videos_progresso/123.jpg');
  });

  test('fromJson aceita registros antigos sem o campo caminhoMiniatura', () {
    final registro = RegistroVideo.fromJson({
      'data': '2026-03-15T00:00:00.000',
      'caminhoArquivo': '/dados/app/videos_progresso/123.mp4',
    });

    expect(registro.caminhoMiniatura, isNull);
  });
}
