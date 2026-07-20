import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/widgets/grafico_linha_simples.dart';

const _chave = Key('grafico-linha-simples');

void main() {
  testWidgets('Com menos de 2 valores, não desenha nada', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: GraficoLinhaSimples(valores: [70]))),
    );

    expect(find.byKey(_chave), findsNothing);
  });

  testWidgets('Com 2 ou mais valores, desenha o gráfico', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: GraficoLinhaSimples(valores: [70, 68, 69]))),
    );

    expect(find.byKey(_chave), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('Com todos os valores iguais, não quebra (intervalo zero)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: GraficoLinhaSimples(valores: [70, 70, 70]))),
    );

    expect(find.byKey(_chave), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
