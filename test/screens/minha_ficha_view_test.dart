import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/models/anamnese.dart';
import 'package:app_personal_trainer/screens/minha_ficha_view.dart';
import 'package:app_personal_trainer/services/anamnese_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Sem anamnese salva, pede para completar o onboarding', (tester) async {
    await tester.pumpWidget(MaterialApp(home: MinhaFichaView()));
    // Não usamos pumpAndSettle: o estado de carregamento mostra um
    // CircularProgressIndicator (animação indeterminada) que nunca "assenta".
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.textContaining('Complete a anamnese'), findsOneWidget);
  });

  testWidgets('Com anamnese salva, mostra os dias de treino gerados', (tester) async {
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
      MaterialApp(home: MinhaFichaView(anamneseRepositorio: repositorio)),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.textContaining('Válida até'), findsOneWidget);
    expect(find.text('Dia 1'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Dia 3'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    expect(find.text('Dia 3'), findsOneWidget);
  });
}
