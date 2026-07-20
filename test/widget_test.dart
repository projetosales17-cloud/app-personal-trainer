import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Sem anamnese salva, o app abre no onboarding', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Bem-vinda!'), findsOneWidget);
  });

  testWidgets('Com anamnese já salva, o app vai direto para a navegação principal', (tester) async {
    SharedPreferences.setMockInitialValues({
      'anamnese':
          '{"idade":30,"alturaCm":170.0,"pesoAtualKg":65.0,"pesoDesejadoKg":null,'
          '"objetivoPrincipal":"emagrecimento","cirurgiaBariatrica":false,'
          '"tipoCirurgiaBariatrica":null,"mesesDesdeCirurgia":null,'
          '"condicaoHormonal":"Nenhuma","restricoesAlimentares":[],"lesoesLimitacoes":[],'
          '"nivelAtividade":"moderado","frequenciaSemanalDias":3,"regioesPriorizadas":[]}',
    });

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Início'), findsWidgets);
    expect(find.byType(NavigationDestination), findsNWidgets(6));
  });
}
