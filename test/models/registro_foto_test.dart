import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/models/registro_foto.dart';

void main() {
  final dataUri = 'data:image/jpeg;base64,${base64Encode([10, 20, 30, 40])}';

  test('toJson/fromJson preservam id, data e dataUri', () {
    final registro = RegistroFoto(
      id: 'abc123',
      data: DateTime(2026, 3, 15),
      dataUri: dataUri,
    );

    final reconstruido = RegistroFoto.fromJson(registro.toJson());

    expect(reconstruido.id, 'abc123');
    expect(reconstruido.data, DateTime(2026, 3, 15));
    expect(reconstruido.dataUri, dataUri);
  });

  test('bytes decodifica o base64 do data URI', () {
    final registro = RegistroFoto(id: 'x', data: DateTime(2026, 1, 1), dataUri: dataUri);
    expect(registro.bytes, [10, 20, 30, 40]);
  });

  test('fromJson tolera registro antigo sem id', () {
    final reconstruido = RegistroFoto.fromJson({
      'data': DateTime(2026, 1, 1).toIso8601String(),
      'dataUri': dataUri,
    });
    expect(reconstruido.id, startsWith('local_'));
  });
}
