import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/widgets/cronometro_descanso.dart';

const _texto = Key('texto-cronometro');
const _iniciar = Key('botao-iniciar-cronometro');
const _parar = Key('botao-parar-cronometro');

Text _textoCronometro(WidgetTester tester) => tester.widget<Text>(find.byKey(_texto));

void main() {
  testWidgets('Mostra a duração inicial parada, sem contar', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CronometroDescanso(duracaoInicial: Duration(seconds: 30)),
        ),
      ),
    );

    expect(_textoCronometro(tester).data, '00:30');
    expect(find.byKey(_iniciar), findsOneWidget);
    expect(find.byKey(_parar), findsNothing);
  });

  testWidgets('Iniciar conta regressivamente a cada segundo', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CronometroDescanso(duracaoInicial: Duration(seconds: 5)),
        ),
      ),
    );

    await tester.tap(find.byKey(_iniciar));
    await tester.pump();

    expect(find.byKey(_parar), findsOneWidget);
    expect(_textoCronometro(tester).data, '00:05');

    await tester.pump(const Duration(seconds: 1));
    expect(_textoCronometro(tester).data, '00:04');

    await tester.pump(const Duration(seconds: 1));
    expect(_textoCronometro(tester).data, '00:03');
  });

  testWidgets('Ao chegar a zero, volta ao estado parado', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CronometroDescanso(duracaoInicial: Duration(seconds: 2)),
        ),
      ),
    );

    await tester.tap(find.byKey(_iniciar));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(_textoCronometro(tester).data, '00:00');
    expect(find.byKey(_iniciar), findsOneWidget);
    expect(find.byKey(_parar), findsNothing);
  });

  testWidgets('Parar interrompe a contagem e reseta para a duração inicial', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CronometroDescanso(duracaoInicial: Duration(seconds: 10)),
        ),
      ),
    );

    await tester.tap(find.byKey(_iniciar));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(_textoCronometro(tester).data, '00:07');

    await tester.tap(find.byKey(_parar));
    await tester.pump();

    expect(_textoCronometro(tester).data, '00:10');
    expect(find.byKey(_iniciar), findsOneWidget);
  });
}
