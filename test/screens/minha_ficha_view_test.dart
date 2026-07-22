import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/models/anamnese.dart';
import 'package:app_personal_trainer/screens/minha_ficha_view.dart';
import 'package:app_personal_trainer/services/anamnese_repository.dart';
import 'package:app_personal_trainer/services/preferencias_repository.dart';

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
    expect(find.textContaining('Datas sugeridas:'), findsWidgets);

    await tester.dragUntilVisible(
      find.text('Dia 3'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    expect(find.text('Dia 3'), findsOneWidget);
  });

  testWidgets(
    'Botão de salvar dias fica desabilitado até escolher a quantidade certa de dias',
    (tester) async {
      final repositorio = AnamneseRepository();
      await repositorio.salvar(
        const Anamnese(
          idade: 30,
          alturaCm: 170,
          pesoAtualKg: 65,
          objetivoPrincipal: Objetivo.hipertrofia,
          nivelAtividade: NivelAtividade.moderado,
          frequenciaSemanalDias: 2,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(home: MinhaFichaView(anamneseRepositorio: repositorio)),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final botaoSalvar = find.byKey(const Key('botao-salvar-dias-treino'));
      expect(tester.widget<ElevatedButton>(botaoSalvar).onPressed, isNull);

      await tester.tap(find.byKey(const Key('dia-semana-1')));
      await tester.pump();
      expect(tester.widget<ElevatedButton>(botaoSalvar).onPressed, isNull);

      await tester.tap(find.byKey(const Key('dia-semana-4')));
      await tester.pump();
      expect(tester.widget<ElevatedButton>(botaoSalvar).onPressed, isNotNull);
    },
  );

  testWidgets('Salvar os dias escolhidos persiste e usa esses dias no calendário', (
    tester,
  ) async {
    final anamneseRepositorio = AnamneseRepository();
    await anamneseRepositorio.salvar(
      const Anamnese(
        idade: 30,
        alturaCm: 170,
        pesoAtualKg: 65,
        objetivoPrincipal: Objetivo.hipertrofia,
        nivelAtividade: NivelAtividade.moderado,
        frequenciaSemanalDias: 2,
      ),
    );
    final preferenciasRepositorio = PreferenciasRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: MinhaFichaView(
          anamneseRepositorio: anamneseRepositorio,
          preferenciasRepositorio: preferenciasRepositorio,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.byKey(const Key('dia-semana-2'))); // terça
    await tester.pump();
    await tester.tap(find.byKey(const Key('dia-semana-5'))); // sexta
    await tester.pump();

    await tester.tap(find.byKey(const Key('botao-salvar-dias-treino')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(await preferenciasRepositorio.diasDaSemanaEscolhidos(), [2, 5]);
  });
}
