import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/models/anamnese.dart';
import 'package:app_personal_trainer/screens/home_screen.dart';
import 'package:app_personal_trainer/services/anamnese_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Sem anamnese salva, pede para completar o onboarding', (tester) async {
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Complete a anamnese'), findsOneWidget);
  });

  testWidgets('Com anamnese salva, mostra o card de treino do dia', (tester) async {
    final repositorio = AnamneseRepository();
    await repositorio.salvar(
      const Anamnese(
        idade: 30,
        alturaCm: 170,
        pesoAtualKg: 65,
        objetivoPrincipal: Objetivo.hipertrofia,
        nivelAtividade: NivelAtividade.moderado,
        frequenciaSemanalDias: 3,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(anamneseRepositorio: repositorio)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Olá!'), findsOneWidget);
    expect(find.text('Treino do dia'), findsOneWidget);
    expect(find.textContaining('Ficha válida até'), findsOneWidget);
    expect(find.text('Alimentação do dia'), findsOneWidget);
    expect(find.text('Progresso'), findsOneWidget);
  });
}
