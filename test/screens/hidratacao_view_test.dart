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

  testWidgets('Sem anamnese salva, mostra a calculadora vazia', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: HidratacaoView())));
    await tester.pumpAndSettle();

    expect(find.textContaining('Ingresa tu peso'), findsOneWidget);
    expect(find.byKey(const Key('campo-peso-hidratacion')), findsOneWidget);
  });

  testWidgets('Vem pré-preenchida com o peso da anamnese e calcula a meta', (tester) async {
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

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: HidratacaoView(repositorio: repositorio))),
    );
    await tester.pumpAndSettle();

    // 60 kg * 35 ml + 0 (sedentária) = 2100 ml.
    expect(find.text('2.1 L por día'), findsOneWidget);

    // Marcar "dia quente" soma 500 ml -> 2.6 L.
    await tester.tap(find.byKey(const Key('switch-dia-quente')));
    await tester.pumpAndSettle();
    expect(find.text('2.6 L por día'), findsOneWidget);
  });
}
