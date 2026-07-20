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
  });
}
