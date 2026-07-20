import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/models/anamnese.dart';
import 'package:app_personal_trainer/screens/meu_cardapio_view.dart';
import 'package:app_personal_trainer/services/anamnese_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Sem anamnese salva, pede para completar o onboarding', (tester) async {
    await tester.pumpWidget(MaterialApp(home: MeuCardapioView()));
    await tester.pump();

    expect(find.textContaining('Complete a anamnese'), findsOneWidget);
  });

  testWidgets('Com anamnese salva, mostra os dias de cardápio gerados', (tester) async {
    final repositorio = AnamneseRepository();
    await repositorio.salvar(
      const Anamnese(
        idade: 30,
        alturaCm: 170,
        pesoAtualKg: 65,
        objetivoPrincipal: Objetivo.emagrecimento,
        nivelAtividade: NivelAtividade.moderado,
        frequenciaSemanalDias: 3,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: MeuCardapioView(anamneseRepositorio: repositorio)),
    );
    await tester.pump();

    expect(find.textContaining('Válido até'), findsOneWidget);
    expect(find.text('Dia 1'), findsOneWidget);
    expect(find.text('Almoço'), findsWidgets);

    await tester.dragUntilVisible(
      find.text('Dia 3'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    expect(find.text('Dia 3'), findsOneWidget);
  });

  testWidgets('Anamnese com cirurgia bariátrica mostra aviso de orientação profissional', (
    tester,
  ) async {
    final repositorio = AnamneseRepository();
    await repositorio.salvar(
      const Anamnese(
        idade: 35,
        alturaCm: 165,
        pesoAtualKg: 80,
        objetivoPrincipal: Objetivo.saudeGeral,
        cirurgiaBariatrica: true,
        nivelAtividade: NivelAtividade.leve,
        frequenciaSemanalDias: 2,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: MeuCardapioView(anamneseRepositorio: repositorio)),
    );
    await tester.pump();

    expect(find.textContaining('não substitui a orientação de um(a) nutricionista'), findsOneWidget);
  });
}
