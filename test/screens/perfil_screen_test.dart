import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/models/anamnese.dart';
import 'package:app_personal_trainer/screens/perfil_screen.dart';
import 'package:app_personal_trainer/services/anamnese_repository.dart';
import 'package:app_personal_trainer/services/preferencias_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Sem anamnese salva, pede para completar o onboarding', (tester) async {
    await tester.pumpWidget(MaterialApp(home: PerfilScreen()));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Complete a anamnese'), findsOneWidget);
  });

  testWidgets('Com anamnese salva, mostra os dados da usuária', (tester) async {
    final anamneseRepositorio = AnamneseRepository();
    await anamneseRepositorio.salvar(
      const Anamnese(
        idade: 30,
        alturaCm: 170,
        pesoAtualKg: 65,
        pesoDesejadoKg: 60,
        objetivoPrincipal: Objetivo.emagrecimento,
        condicaoHormonal: 'Menopausa',
        restricoesAlimentares: ['Lactose'],
        nivelAtividade: NivelAtividade.moderado,
        frequenciaSemanalDias: 3,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: PerfilScreen(anamneseRepositorio: anamneseRepositorio)),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('30 anos'), findsOneWidget);
    expect(find.text('170 cm'), findsOneWidget);
    expect(find.text('65.0 kg'), findsOneWidget);
    expect(find.text('60.0 kg'), findsOneWidget);
    expect(find.text('Emagrecimento'), findsOneWidget);
    expect(find.text('Menopausa'), findsOneWidget);
    expect(find.text('Lactose'), findsOneWidget);
  });

  testWidgets('Alternar o switch de notificações persiste a preferência', (tester) async {
    final preferenciasRepositorio = PreferenciasRepository();
    await tester.pumpWidget(
      MaterialApp(home: PerfilScreen(preferenciasRepositorio: preferenciasRepositorio)),
    );
    await tester.pump();
    await tester.pump();

    expect(
      tester.widget<SwitchListTile>(find.byKey(const Key('switch-notificacoes'))).value,
      isTrue,
    );

    await tester.tap(find.byKey(const Key('switch-notificacoes')));
    await tester.pumpAndSettle();

    expect(await preferenciasRepositorio.notificacoesAtivadas(), isFalse);
    expect(
      tester.widget<SwitchListTile>(find.byKey(const Key('switch-notificacoes'))).value,
      isFalse,
    );
  });

  testWidgets('Mostra avisos de assinatura e suporte ainda pendentes', (tester) async {
    await tester.pumpWidget(MaterialApp(home: PerfilScreen()));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('depende de uma decisão de'), findsOneWidget);
    expect(find.textContaining('Canal de suporte em breve'), findsOneWidget);
  });
}
