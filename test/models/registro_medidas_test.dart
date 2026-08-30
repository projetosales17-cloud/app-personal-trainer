import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/models/registro_medidas.dart';

void main() {
  test('toJson/fromJson preservam data e medidas informadas', () {
    final registro = RegistroMedidas(
      data: DateTime(2026, 3, 15),
      cinturaCm: 80,
      quadrilCm: 100,
    );

    final json = registro.toJson();
    final reconstruido = RegistroMedidas.fromJson(json);

    expect(reconstruido.data, DateTime(2026, 3, 15));
    expect(reconstruido.cinturaCm, 80);
    expect(reconstruido.quadrilCm, 100);
    expect(reconstruido.bracoCm, isNull);
    expect(reconstruido.coxaCm, isNull);
  });

  test('vazio é verdadeiro quando nenhuma medida foi informada', () {
    final registro = RegistroMedidas(data: DateTime.now());
    expect(registro.vazio, isTrue);
  });

  test('vazio é falso quando pelo menos uma medida foi informada', () {
    final registro = RegistroMedidas(data: DateTime.now(), bracoCm: 30);
    expect(registro.vazio, isFalse);
  });

  test('tórax, antebraço, panturrilha e pescoço sobrevivem ao round-trip', () {
    final registro = RegistroMedidas(
      data: DateTime(2026, 3, 15),
      pescocoCm: 34,
      toraxCm: 92,
      antebracoCm: 26,
      panturrilhaCm: 37,
    );
    final r = RegistroMedidas.fromJson(registro.toJson());
    expect(r.pescocoCm, 34);
    expect(r.toraxCm, 92);
    expect(r.antebracoCm, 26);
    expect(r.panturrilhaCm, 37);
  });

  test('todas lista as 8 medidas na ordem de cima para baixo', () {
    final registro = RegistroMedidas(data: DateTime.now(), toraxCm: 92, coxaCm: 55);
    expect(
      registro.todas.map((m) => m.$1),
      ['Cuello', 'Tórax', 'Brazo', 'Antebrazo', 'Cintura', 'Cadera', 'Muslo', 'Pantorrilla'],
    );
    expect(registro.vazio, isFalse);
  });

  test('registro antigo (só cintura/quadril/braço/coxa) continua lendo', () {
    final r = RegistroMedidas.fromJson({
      'data': '2026-03-15T00:00:00.000',
      'cinturaCm': 80,
      'coxaCm': 55,
    });
    expect(r.cinturaCm, 80);
    expect(r.coxaCm, 55);
    expect(r.toraxCm, isNull);
    expect(r.pescocoCm, isNull);
  });

  test('id sobrevive ao round-trip e registro antigo sem id cai na data', () {
    final registro = RegistroMedidas(data: DateTime(2026, 3, 15), cinturaCm: 80);
    expect(RegistroMedidas.fromJson(registro.toJson()).id, registro.id);
    expect(
      RegistroMedidas.fromJson({'data': '2026-03-15T00:00:00.000', 'cinturaCm': 80}).id,
      '2026-03-15T00:00:00.000',
    );
  });
}
