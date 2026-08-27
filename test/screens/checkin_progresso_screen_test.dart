import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/models/checkin_progresso.dart';
import 'package:app_personal_trainer/screens/checkin_progresso_screen.dart';
import 'package:app_personal_trainer/services/programa_treino_repository.dart';
import 'package:app_personal_trainer/services/progresso_repository.dart';

Future<void> _tocar(WidgetTester tester, Finder alvo) async {
  await tester.scrollUntilVisible(alvo, 60, scrollable: find.byType(Scrollable).first);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('o botão de enviar só habilita depois de responder as 3 perguntas', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: CheckinProgressoScreen(blocoConcluido: 1)),
    );

    final botao = find.byKey(const Key('botao-enviar-checkin'));
    expect(tester.widget<FilledButton>(botao).onPressed, isNull);

    await _tocar(tester, find.text('Conseguí entrenar casi todo'));
    await _tocar(tester, find.text('En su punto'));
    await _tocar(tester, find.text('Bien recuperada'));

    expect(tester.widget<FilledButton>(botao).onPressed, isNotNull);
  });

  testWidgets('enviar grava o check-in, avança o bloco e mostra o resultado', (tester) async {
    final progresso = ProgressoRepository();
    final repo = ProgramaTreinoRepository(progressoRepositorio: progresso);
    await repo.iniciarSeNecessario();

    await tester.pumpWidget(
      MaterialApp(
        home: CheckinProgressoScreen(
          blocoConcluido: 1,
          programaRepositorio: repo,
          pesoSugerido: 65,
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('campo-peso-checkin')), '64');
    await _tocar(tester, find.text('Entrené poco'));
    await _tocar(tester, find.text('Demasiado difícil'));
    await _tocar(tester, find.text('Muy cansada'));

    final botao = find.byKey(const Key('botao-enviar-checkin'));
    await tester.ensureVisible(botao);
    await tester.pump();
    expect(tester.widget<FilledButton>(botao).onPressed, isNotNull);
    await tester.tap(botao);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byKey(const Key('botao-ver-nova-rutina')), findsOneWidget);
    await tester.tap(find.byKey(const Key('botao-ver-nova-rutina')));
    await tester.pumpAndSettle();

    final programa = await repo.carregar();
    expect(programa!.blocoAtual, 2);
    expect(programa.checkins.single.aderencia, AderenciaPercebida.pouco);
    expect((await progresso.ultimoPeso())!.pesoKg, 64);
  });
}
