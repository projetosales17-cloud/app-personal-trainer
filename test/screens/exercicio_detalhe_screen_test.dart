import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/data/biblioteca_exercicios.dart';
import 'package:app_personal_trainer/models/registro_carga.dart';
import 'package:app_personal_trainer/screens/exercicio_detalhe_screen.dart';
import 'package:app_personal_trainer/services/treino_repository.dart';

final _flexao = bibliotecaExercicios.first;

const _lista = Key('lista-exercicio-detalhe');

// A seção de histórico fica abaixo da dobra na tela de detalhe (chips +
// instruções + formulário de carga já ocupam a viewport de teste), então
// precisamos rolar até o conteúdo antes de fazer qualquer asserção sobre
// ele — do contrário o finder o considera "offstage" mesmo já construído.
Future<void> _rolarAte(WidgetTester tester, Finder finder) =>
    tester.dragUntilVisible(finder, find.byKey(_lista), const Offset(0, -300));

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Sem histórico, mostra estado vazio', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ExercicioDetalheScreen(exercicio: _flexao)));
    await tester.pump();
    await tester.pump();
    await _rolarAte(tester, find.textContaining('Nenhum registro de carga ainda'));

    expect(find.textContaining('Nenhum registro de carga ainda'), findsOneWidget);
  });

  testWidgets('Registrar uma carga adiciona ao histórico e limpa os campos', (tester) async {
    final repositorio = TreinoRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: ExercicioDetalheScreen(exercicio: _flexao, repositorio: repositorio),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byKey(const Key('campo-peso-carga')), '0');
    await tester.enterText(find.byKey(const Key('campo-series')), '3');
    await tester.enterText(find.byKey(const Key('campo-repeticoes')), '15');
    await tester.tap(find.byKey(const Key('botao-registrar-carga')));
    await tester.pumpAndSettle();
    await _rolarAte(tester, find.text('0.0 kg · 3x15'));

    expect(find.text('0.0 kg · 3x15'), findsOneWidget);

    final campoPeso = tester.widget<TextField>(find.byKey(const Key('campo-peso-carga')));
    expect(campoPeso.controller!.text, isEmpty);
  });

  testWidgets('Histórico só mostra registros do exercício aberto', (tester) async {
    final repositorio = TreinoRepository();
    final outroExercicio = bibliotecaExercicios[1];
    await repositorio.registrarCarga(
      RegistroCarga(
        exercicioId: outroExercicio.id,
        data: DateTime(2026, 1, 1),
        pesoKg: 10,
        series: 3,
        repeticoes: 12,
      ),
    );
    await repositorio.registrarCarga(
      RegistroCarga(
        exercicioId: _flexao.id,
        data: DateTime(2026, 1, 2),
        pesoKg: 0,
        series: 3,
        repeticoes: 15,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ExercicioDetalheScreen(exercicio: _flexao, repositorio: repositorio),
      ),
    );
    await tester.pump();
    await tester.pump();
    await _rolarAte(tester, find.byType(ListTile));

    expect(find.textContaining('Nenhum registro de carga ainda'), findsNothing);
    final tiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
    expect(tiles, hasLength(1));
  });

  testWidgets('Campos inválidos não registram nada', (tester) async {
    final repositorio = TreinoRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: ExercicioDetalheScreen(exercicio: _flexao, repositorio: repositorio),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byKey(const Key('campo-peso-carga')), 'abc');
    await tester.tap(find.byKey(const Key('botao-registrar-carga')));
    await tester.pumpAndSettle();
    await _rolarAte(tester, find.textContaining('Nenhum registro de carga ainda'));

    expect(find.textContaining('Nenhum registro de carga ainda'), findsOneWidget);
  });

  testWidgets('Peso 0 registra normalmente (exercício de peso do corpo)', (tester) async {
    final repositorio = TreinoRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: ExercicioDetalheScreen(exercicio: _flexao, repositorio: repositorio),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byKey(const Key('campo-peso-carga')), '0');
    await tester.enterText(find.byKey(const Key('campo-series')), '3');
    await tester.enterText(find.byKey(const Key('campo-repeticoes')), '20');
    await tester.tap(find.byKey(const Key('botao-registrar-carga')));
    await tester.pumpAndSettle();
    await _rolarAte(tester, find.text('0.0 kg · 3x20'));

    expect(find.text('0.0 kg · 3x20'), findsOneWidget);
  });
}
