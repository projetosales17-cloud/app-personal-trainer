import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/data/biblioteca_exercicios.dart';
import 'package:app_personal_trainer/models/registro_carga.dart';
import 'package:app_personal_trainer/screens/evolucao_carga_view.dart';
import 'package:app_personal_trainer/services/treino_repository.dart';

final _exA = bibliotecaExercicios[0];
final _exB = bibliotecaExercicios[1];

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Sem histórico suficiente, mostra o estado vazio', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: EvolucaoCargaView())));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Registre a carga dos seus exercícios'), findsOneWidget);
  });

  testWidgets('Com 2+ registros de um exercício, mostra o cartão de evolução', (tester) async {
    final repositorio = TreinoRepository();
    await repositorio.registrarCarga(RegistroCarga(
      exercicioId: _exA.id,
      data: DateTime.now().subtract(const Duration(days: 28)),
      pesoKg: 20,
      series: 3,
      repeticoes: 10,
    ));
    await repositorio.registrarCarga(RegistroCarga(
      exercicioId: _exA.id,
      data: DateTime.now(),
      pesoKg: 30,
      series: 3,
      repeticoes: 10,
    ));
    // Exercício com um só registro não deve aparecer.
    await repositorio.registrarCarga(RegistroCarga(
      exercicioId: _exB.id,
      data: DateTime.now(),
      pesoKg: 5,
      series: 3,
      repeticoes: 10,
    ));

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: EvolucaoCargaView(treinoRepositorio: repositorio))),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text(_exA.nome), findsOneWidget);
    expect(find.text(_exB.nome), findsNothing);
    expect(find.textContaining('De 20 kg para 30 kg'), findsOneWidget);
    expect(find.textContaining('aumentou a carga em 1 exercício'), findsOneWidget);
    expect(find.byKey(const Key('grafico-linha-simples')), findsOneWidget);
  });
}
