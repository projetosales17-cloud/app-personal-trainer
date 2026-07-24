import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/models/checkin_treino.dart';

void main() {
  test('toJson/fromJson preservam todos os campos', () {
    final checkin = CheckinTreino(data: DateTime(2026, 3, 15), diaFicha: 2);

    final json = checkin.toJson();
    final reconstruido = CheckinTreino.fromJson(json);

    expect(reconstruido.data, DateTime(2026, 3, 15));
    expect(reconstruido.diaFicha, 2);
  });
}
