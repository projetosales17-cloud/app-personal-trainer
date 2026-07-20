import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/screens/onboarding/onboarding_flow.dart';
import 'package:app_personal_trainer/services/anamnese_repository.dart';

Future<void> _avancar(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'Avançar'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Botão Avançar fica desabilitado até a licença ser preenchida', (tester) async {
    var concluido = false;
    await tester.pumpWidget(MaterialApp(
      home: OnboardingFlow(onConcluido: () => concluido = true),
    ));

    await _avancar(tester); // boas-vindas -> licença

    final botaoDesabilitado =
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Avançar'));
    expect(botaoDesabilitado.onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'ABC-123');
    await tester.pump();

    final botaoHabilitado =
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Avançar'));
    expect(botaoHabilitado.onPressed, isNotNull);

    expect(concluido, isFalse);
  });

  testWidgets('Completar o fluxo salva a anamnese e chama onConcluido', (tester) async {
    var concluido = false;
    final repositorio = AnamneseRepository();

    await tester.pumpWidget(MaterialApp(
      home: OnboardingFlow(onConcluido: () => concluido = true, repositorio: repositorio),
    ));

    await _avancar(tester); // boas-vindas -> licença

    await tester.enterText(find.byType(TextField), 'ABC-123');
    await tester.pump();
    await _avancar(tester); // licença -> conta

    await tester.enterText(find.byType(TextField).at(0), 'Maria');
    await tester.enterText(find.byType(TextField).at(1), 'maria@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'senha123');
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await _avancar(tester); // conta -> dados básicos

    await tester.enterText(find.byType(TextField).at(0), '30');
    await tester.enterText(find.byType(TextField).at(1), '170');
    await tester.enterText(find.byType(TextField).at(2), '65');
    await tester.pump();
    await _avancar(tester); // dados básicos -> objetivo

    await tester.tap(find.text('Emagrecimento'));
    await tester.pump();
    await _avancar(tester); // objetivo -> cirurgia bariátrica

    await _avancar(tester); // bariátrica (não) -> condição hormonal

    await _avancar(tester); // condição hormonal (padrão) -> restrições

    await _avancar(tester); // restrições -> lesões

    await _avancar(tester); // lesões -> atividade

    await tester.tap(find.text('Moderado'));
    await tester.pump();
    await _avancar(tester); // atividade -> priorização de região

    await _avancar(tester); // priorização de região -> resumo

    expect(find.text('Resumo'), findsOneWidget);

    // Não usamos pumpAndSettle aqui: o passo de resumo mostra um
    // CircularProgressIndicator (animação indeterminada) enquanto salva,
    // que nunca "assenta" e faria pumpAndSettle estourar o tempo limite.
    await tester.tap(find.widgetWithText(FilledButton, 'Concluir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(concluido, isTrue);

    final salvo = await repositorio.carregar();
    expect(salvo, isNotNull);
    expect(salvo!.idade, 30);
    expect(salvo.alturaCm, 170);
    expect(salvo.pesoAtualKg, 65);
    expect(salvo.objetivoPrincipal.name, 'emagrecimento');
    expect(salvo.nivelAtividade.name, 'moderado');
    expect(salvo.cirurgiaBariatrica, isFalse);
  });
}
