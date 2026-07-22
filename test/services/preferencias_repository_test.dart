import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/services/preferencias_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('notificacoesAtivadas é verdadeiro por padrão quando nada foi definido', () async {
    final repositorio = PreferenciasRepository();
    expect(await repositorio.notificacoesAtivadas(), isTrue);
  });

  test('definirNotificacoesAtivadas persiste o valor', () async {
    final repositorio = PreferenciasRepository();
    await repositorio.definirNotificacoesAtivadas(false);
    expect(await repositorio.notificacoesAtivadas(), isFalse);

    await repositorio.definirNotificacoesAtivadas(true);
    expect(await repositorio.notificacoesAtivadas(), isTrue);
  });

  test('diasDaSemanaEscolhidos é nulo por padrão quando nada foi definido', () async {
    final repositorio = PreferenciasRepository();
    expect(await repositorio.diasDaSemanaEscolhidos(), isNull);
  });

  test('definirDiasDaSemanaEscolhidos persiste os dias em ordem crescente', () async {
    final repositorio = PreferenciasRepository();
    await repositorio.definirDiasDaSemanaEscolhidos([5, 1, 3]);

    expect(await repositorio.diasDaSemanaEscolhidos(), [1, 3, 5]);
  });
}
