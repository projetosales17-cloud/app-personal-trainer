import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/models/registro_foto.dart';

void main() {
  test('toJson/fromJson preservam data e caminho do arquivo', () {
    final registro = RegistroFoto(
      data: DateTime(2026, 3, 15),
      caminhoArquivo: '/dados/app/fotos_progresso/123.png',
    );

    final json = registro.toJson();
    final reconstruido = RegistroFoto.fromJson(json);

    expect(reconstruido.data, DateTime(2026, 3, 15));
    expect(reconstruido.caminhoArquivo, '/dados/app/fotos_progresso/123.png');
  });
}
