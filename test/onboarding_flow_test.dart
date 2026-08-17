import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/screens/onboarding/onboarding_flow.dart';
import 'package:app_personal_trainer/services/anamnese_repository.dart';

Future<void> _avancar(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'Siguiente'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Botão Avançar fica desabilitado até os dados básicos serem preenchidos', (
    tester,
  ) async {
    var concluido = false;
    await tester.pumpWidget(MaterialApp(
      home: OnboardingFlow(onConcluido: () => concluido = true),
    ));

    await _avancar(tester); // boas-vindas -> dados básicos

    final botaoDesabilitado =
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Siguiente'));
    expect(botaoDesabilitado.onPressed, isNull);

    await tester.enterText(find.byType(TextField).at(0), '30');
    await tester.enterText(find.byType(TextField).at(1), '170');
    await tester.enterText(find.byType(TextField).at(2), '65');
    await tester.pump();

    final botaoHabilitado =
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Siguiente'));
    expect(botaoHabilitado.onPressed, isNotNull);

    expect(concluido, isFalse);
  });

  testWidgets('Completar o fluxo salva a anamnese e chama onConcluido', (tester) async {
    var concluido = false;
    final repositorio = AnamneseRepository();

    await tester.pumpWidget(MaterialApp(
      home: OnboardingFlow(onConcluido: () => concluido = true, repositorio: repositorio),
    ));

    await _avancar(tester); // boas-vindas -> dados básicos

    await tester.enterText(find.byType(TextField).at(0), '30');
    await tester.enterText(find.byType(TextField).at(1), '170');
    await tester.enterText(find.byType(TextField).at(2), '65');
    await tester.pump();
    await _avancar(tester); // dados básicos -> objetivo

    await tester.tap(find.text('Pérdida de peso'));
    await tester.pump();
    await _avancar(tester); // objetivo -> cirurgia bariátrica

    await _avancar(tester); // bariátrica (não) -> condição hormonal

    await _avancar(tester); // condição hormonal (padrão) -> ciclo menstrual

    await _avancar(tester); // ciclo menstrual (padrão) -> restrições

    await _avancar(tester); // restrições -> lesões

    await _avancar(tester); // lesões -> pós-parto

    await _avancar(tester); // pós-parto (não) -> atividade

    await tester.tap(find.text('Moderada'));
    await tester.pump();
    await _avancar(tester); // atividade -> local de treino

    await tester.tap(find.text('Gimnasio'));
    await tester.pump();
    await _avancar(tester); // local de treino -> preferência de treino (já vem pré-selecionada)

    await _avancar(tester); // preferência de treino -> priorização de região

    await _avancar(tester); // priorização de região -> resumo

    expect(find.text('Resumen'), findsOneWidget);

    // Não usamos pumpAndSettle aqui: o passo de resumo mostra um
    // CircularProgressIndicator (animação indeterminada) enquanto salva,
    // que nunca "assenta" e faria pumpAndSettle estourar o tempo limite.
    await tester.tap(find.widgetWithText(FilledButton, 'Finalizar'));
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

  testWidgets('Resumo mostra IMC, TMB e gasto calórico calculados', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: OnboardingFlow(onConcluido: () {}),
    ));

    await _avancar(tester); // boas-vindas -> dados básicos

    await tester.enterText(find.byType(TextField).at(0), '30');
    await tester.enterText(find.byType(TextField).at(1), '175');
    await tester.enterText(find.byType(TextField).at(2), '70');
    await tester.pump();
    await _avancar(tester); // dados básicos -> objetivo

    await tester.tap(find.text('Pérdida de peso'));
    await tester.pump();
    await _avancar(tester); // objetivo -> cirurgia bariátrica

    await _avancar(tester); // bariátrica (não) -> condição hormonal
    await _avancar(tester); // condição hormonal (padrão) -> ciclo menstrual

    await _avancar(tester); // ciclo menstrual (padrão) -> restrições
    await _avancar(tester); // restrições -> lesões
    await _avancar(tester); // lesões -> pós-parto

    await _avancar(tester); // pós-parto (não) -> atividade

    await tester.tap(find.text('Moderada'));
    await tester.pump();
    await _avancar(tester); // atividade -> local de treino

    await tester.tap(find.text('Gimnasio'));
    await tester.pump();
    await _avancar(tester); // local de treino -> preferência de treino (já vem pré-selecionada)

    await _avancar(tester); // preferência de treino -> priorização de região

    await _avancar(tester); // priorização de região -> resumo

    expect(find.text('IMC: 22.86 (Peso normal)'), findsOneWidget);
    expect(find.text('Tasa Metabólica Basal: 1482.75 kcal/día'), findsOneWidget);
    expect(find.text('Gasto calórico diario estimado: 2298.26 kcal'), findsOneWidget);
    expect(find.textContaining('ATENCIÓN'), findsNothing);
  });

  testWidgets('Ativar "tive um parto recente" sem escolher data salva sem data do parto', (
    tester,
  ) async {
    final repositorio = AnamneseRepository();

    await tester.pumpWidget(MaterialApp(
      home: OnboardingFlow(onConcluido: () {}, repositorio: repositorio),
    ));

    await _avancar(tester); // boas-vindas -> dados básicos

    await tester.enterText(find.byType(TextField).at(0), '28');
    await tester.enterText(find.byType(TextField).at(1), '165');
    await tester.enterText(find.byType(TextField).at(2), '68');
    await tester.pump();
    await _avancar(tester); // dados básicos -> objetivo

    await tester.tap(find.text('Tonificación'));
    await tester.pump();
    await _avancar(tester); // objetivo -> cirurgia bariátrica

    await _avancar(tester); // bariátrica (não) -> condição hormonal
    await _avancar(tester); // condição hormonal (padrão) -> ciclo menstrual
    await _avancar(tester); // ciclo menstrual (padrão) -> restrições
    await _avancar(tester); // restrições -> lesões
    await _avancar(tester); // lesões -> pós-parto

    expect(find.text('Fecha del parto'), findsNothing);
    await tester.tap(find.widgetWithText(SwitchListTile, 'Tuve un parto reciente'));
    await tester.pump();
    expect(find.text('Fecha del parto'), findsOneWidget);

    await _avancar(tester); // pós-parto (sim, sem data) -> atividade

    await tester.tap(find.text('Leve'));
    await tester.pump();
    await _avancar(tester); // atividade -> local de treino

    await tester.tap(find.text('Gimnasio'));
    await tester.pump();
    await _avancar(tester); // local de treino -> preferência de treino

    await _avancar(tester); // preferência de treino -> priorização de região
    await _avancar(tester); // priorização de região -> resumo

    await tester.tap(find.widgetWithText(FilledButton, 'Finalizar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final salvo = await repositorio.carregar();
    expect(salvo, isNotNull);
    expect(salvo!.dataParto, isNull);
  });

  testWidgets('Desligar "ciclo regular" salva sem data da última menstruação', (tester) async {
    final repositorio = AnamneseRepository();

    await tester.pumpWidget(MaterialApp(
      home: OnboardingFlow(onConcluido: () {}, repositorio: repositorio),
    ));

    await _avancar(tester); // boas-vindas -> dados básicos

    await tester.enterText(find.byType(TextField).at(0), '48');
    await tester.enterText(find.byType(TextField).at(1), '165');
    await tester.enterText(find.byType(TextField).at(2), '70');
    await tester.pump();
    await _avancar(tester); // dados básicos -> objetivo

    await tester.tap(find.text('Salud general (ej: menopausia)'));
    await tester.pump();
    await _avancar(tester); // objetivo -> cirurgia bariátrica

    await _avancar(tester); // bariátrica (não) -> condição hormonal
    await _avancar(tester); // condição hormonal (padrão) -> ciclo menstrual

    expect(find.text('Fecha de la última menstruación'), findsOneWidget);
    await tester.tap(find.widgetWithText(SwitchListTile, 'Mi ciclo es regular'));
    await tester.pump();
    expect(find.text('Fecha de la última menstruación'), findsNothing);

    await _avancar(tester); // ciclo menstrual (irregular) -> restrições
    await _avancar(tester); // restrições -> lesões
    await _avancar(tester); // lesões -> pós-parto
    await _avancar(tester); // pós-parto (não) -> atividade

    await tester.tap(find.text('Leve'));
    await tester.pump();
    await _avancar(tester); // atividade -> local de treino

    await tester.tap(find.text('Gimnasio'));
    await tester.pump();
    await _avancar(tester); // local de treino -> preferência de treino

    await _avancar(tester); // preferência de treino -> priorização de região
    await _avancar(tester); // priorização de região -> resumo

    await tester.tap(find.widgetWithText(FilledButton, 'Finalizar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final salvo = await repositorio.carregar();
    expect(salvo, isNotNull);
    expect(salvo!.cicloMenstrualRegular, isFalse);
    expect(salvo.dataUltimaMenstruacao, isNull);
    expect(salvo.faseCiclo, isNull);
  });
}
