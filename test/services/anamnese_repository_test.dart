import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/models/anamnese.dart';
import 'package:app_personal_trainer/services/anamnese_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('onboardingConcluido é falso quando nada foi salvo', () async {
    final repositorio = AnamneseRepository();
    expect(await repositorio.onboardingConcluido(), isFalse);
    expect(await repositorio.carregar(), isNull);
  });

  test('salvar e carregar preservam os dados', () async {
    final repositorio = AnamneseRepository();
    const anamnese = Anamnese(
      idade: 28,
      alturaCm: 172,
      pesoAtualKg: 70,
      objetivoPrincipal: Objetivo.emagrecimento,
      nivelAtividade: NivelAtividade.moderado,
      frequenciaSemanalDias: 3,
    );

    await repositorio.salvar(anamnese);

    expect(await repositorio.onboardingConcluido(), isTrue);
    final carregado = await repositorio.carregar();
    expect(carregado, isNotNull);
    expect(carregado!.idade, 28);
    expect(carregado.objetivoPrincipal, Objetivo.emagrecimento);
  });
}
