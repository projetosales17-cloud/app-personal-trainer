import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/models/anamnese.dart';
import 'package:app_personal_trainer/screens/hidratacao_view.dart';
import 'package:app_personal_trainer/services/anamnese_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Sem anamnese salva, pede para completar o onboarding', (tester) async {
    await tester.pumpWidget(MaterialApp(home: HidratacaoView()));
    await tester.pump();

    expect(find.textContaining('Complete a anamnese'), findsOneWidget);
  });

  testWidgets('Com anamnese salva, mostra a meta de hidratação calculada', (tester) async {
    final repositorio = AnamneseRepository();
    await repositorio.salvar(
      const Anamnese(
        idade: 30,
        alturaCm: 165,
        pesoAtualKg: 60,
        objetivoPrincipal: Objetivo.saudeGeral,
        nivelAtividade: NivelAtividade.sedentario,
        frequenciaSemanalDias: 2,
      ),
    );

    await tester.pumpWidget(MaterialApp(home: HidratacaoView(repositorio: repositorio)));
    await tester.pump();

    expect(find.text('2.1 L por dia'), findsOneWidget);
  });
}
