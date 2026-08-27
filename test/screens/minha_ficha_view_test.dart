import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/models/anamnese.dart';
import 'package:app_personal_trainer/models/exercicio.dart';
import 'package:app_personal_trainer/models/programa_treino.dart';
import 'package:app_personal_trainer/screens/minha_ficha_view.dart';
import 'package:app_personal_trainer/services/anamnese_repository.dart';
import 'package:app_personal_trainer/services/checkin_treino_repository.dart';
import 'package:app_personal_trainer/services/notificador_conquistas.dart';
import 'package:app_personal_trainer/services/preferencias_repository.dart';

class _NotificadorFake implements NotificadorConquistas {
  final chamadas = <String>[];

  @override
  Future<void> notificar({required String titulo, required String corpo}) async {
    chamadas.add(titulo);
  }
}

/// A tela encadeia vários FutureBuilders (anamnese → dias → programa →
/// check-ins). Bombeia frames suficientes para todos resolverem sem usar
/// pumpAndSettle (o estado de carregamento tem CircularProgressIndicator).
Future<void> _carregar(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

Future<void> _tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await _carregar(tester);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Sem anamnese salva, pede para completar o onboarding', (tester) async {
    await tester.pumpWidget(MaterialApp(home: MinhaFichaView()));
    // Não usamos pumpAndSettle: o estado de carregamento mostra um
    // CircularProgressIndicator (animação indeterminada) que nunca "assenta".
    await _carregar(tester);

    expect(find.textContaining('Completa la anamnesis'), findsOneWidget);
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
    await _carregar(tester);

    expect(find.textContaining('Válida hasta'), findsOneWidget);
    expect(find.text('Día 1'), findsOneWidget);
    expect(find.textContaining('Fechas sugeridas:'), findsWidgets);

    await tester.dragUntilVisible(
      find.text('Día 3'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    expect(find.text('Día 3'), findsOneWidget);
  });

  testWidgets('Preferência combinada mostra atividade de cardio no dia', (tester) async {
    final repositorio = AnamneseRepository();
    await repositorio.salvar(
      const Anamnese(
        idade: 30,
        alturaCm: 170,
        pesoAtualKg: 65,
        objetivoPrincipal: Objetivo.emagrecimento,
        nivelAtividade: NivelAtividade.moderado,
        frequenciaSemanalDias: 3,
        preferenciaTreino: PreferenciaTreino.combinado,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: MinhaFichaView(anamneseRepositorio: repositorio)),
    );
    await _carregar(tester);

    expect(find.textContaining('min sugeridos'), findsWidgets);
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
      await _carregar(tester);

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
    await _carregar(tester);

    await tester.tap(find.byKey(const Key('dia-semana-2'))); // terça
    await tester.pump();
    await tester.tap(find.byKey(const Key('dia-semana-5'))); // sexta
    await tester.pump();

    await tester.tap(find.byKey(const Key('botao-salvar-dias-treino')));
    await _carregar(tester);

    expect(await preferenciasRepositorio.diasDaSemanaEscolhidos(), [2, 5]);
  });

  testWidgets('Marcar o check-in do dia 1 de hoje persiste e reflete na tela', (tester) async {
    final anamneseRepositorio = AnamneseRepository();
    await anamneseRepositorio.salvar(
      const Anamnese(
        idade: 30,
        alturaCm: 170,
        pesoAtualKg: 65,
        objetivoPrincipal: Objetivo.hipertrofia,
        nivelAtividade: NivelAtividade.moderado,
        frequenciaSemanalDias: 3,
      ),
    );
    final checkinRepositorio = CheckinTreinoRepository();
    final hoje = DateTime.now();
    final chaveHoje = Key(
      'checkin-dia-1-${hoje.toIso8601String().substring(0, 10)}',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MinhaFichaView(
          anamneseRepositorio: anamneseRepositorio,
          checkinRepositorio: checkinRepositorio,
        ),
      ),
    );
    await _carregar(tester);

    expect(tester.widget<CheckboxListTile>(find.byKey(chaveHoje)).value, isFalse);
    expect(await checkinRepositorio.foiConcluido(hoje, 1), isFalse);

    await _tocar(tester, find.byKey(chaveHoje));

    expect(tester.widget<CheckboxListTile>(find.byKey(chaveHoje)).value, isTrue);
    expect(await checkinRepositorio.foiConcluido(hoje, 1), isTrue);
  });

  testWidgets(
    '2 treinos seguidos pulados mostram o aviso de retomada e reduzem a ficha',
    (tester) async {
      final anamneseRepositorio = AnamneseRepository();
      await anamneseRepositorio.salvar(
        const Anamnese(
          idade: 30,
          alturaCm: 170,
          pesoAtualKg: 65,
          objetivoPrincipal: Objetivo.hipertrofia,
          nivelAtividade: NivelAtividade.moderado,
          frequenciaSemanalDias: 1,
        ),
      );
      final preferenciasRepositorio = PreferenciasRepository();
      await preferenciasRepositorio.definirDiasDaSemanaEscolhidos([DateTime.now().weekday]);

      await tester.pumpWidget(
        MaterialApp(
          home: MinhaFichaView(
            anamneseRepositorio: anamneseRepositorio,
            preferenciasRepositorio: preferenciasRepositorio,
          ),
        ),
      );
      await _carregar(tester);

      expect(find.textContaining('saltaste los últimos entrenamientos'), findsOneWidget);
    },
  );

  testWidgets('Com check-in recente, não mostra o aviso de retomada', (tester) async {
    final anamneseRepositorio = AnamneseRepository();
    await anamneseRepositorio.salvar(
      const Anamnese(
        idade: 30,
        alturaCm: 170,
        pesoAtualKg: 65,
        objetivoPrincipal: Objetivo.hipertrofia,
        nivelAtividade: NivelAtividade.moderado,
        frequenciaSemanalDias: 1,
      ),
    );
    final preferenciasRepositorio = PreferenciasRepository();
    await preferenciasRepositorio.definirDiasDaSemanaEscolhidos([DateTime.now().weekday]);
    final checkinRepositorio = CheckinTreinoRepository();
    await checkinRepositorio.marcarConcluido(
      DateTime.now().subtract(const Duration(days: 7)),
      1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MinhaFichaView(
          anamneseRepositorio: anamneseRepositorio,
          preferenciasRepositorio: preferenciasRepositorio,
          checkinRepositorio: checkinRepositorio,
        ),
      ),
    );
    await _carregar(tester);

    expect(find.textContaining('saltaste los últimos entrenamientos'), findsNothing);
  });

  testWidgets('Bloco vencido mostra o cartão de check-in de progresso', (tester) async {
    final agora = DateTime.now();
    final programa = ProgramaTreino(
      iniciadoEm: agora.subtract(const Duration(days: 50)),
      blocoAtual: 1,
      blocoIniciadoEm: agora.subtract(const Duration(days: 45)),
      nivelLiberado: NivelExercicio.iniciante,
    );
    SharedPreferences.setMockInitialValues({
      'programa_treino': jsonEncode(programa.toJson()),
    });

    final anamneseRepositorio = AnamneseRepository();
    await anamneseRepositorio.salvar(
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
      MaterialApp(home: MinhaFichaView(anamneseRepositorio: anamneseRepositorio)),
    );
    await _carregar(tester);

    expect(find.byKey(const Key('cartao-checkin-disponivel')), findsOneWidget);
    expect(find.byKey(const Key('botao-abrir-checkin')), findsOneWidget);
  });

  testWidgets('Mostra o cartão de gamificação com streak e pontos', (tester) async {
    final anamneseRepositorio = AnamneseRepository();
    await anamneseRepositorio.salvar(
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
      MaterialApp(home: MinhaFichaView(anamneseRepositorio: anamneseRepositorio)),
    );
    await _carregar(tester);

    expect(find.textContaining('Racha: 0 día(s)'), findsOneWidget);
    expect(find.textContaining('0 puntos'), findsOneWidget);
  });

  testWidgets('Bater um marco de streak (3 dias) dispara uma notificação de conquista', (
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
        frequenciaSemanalDias: 1,
      ),
    );
    final preferenciasRepositorio = PreferenciasRepository();
    final hoje = DateTime.now();
    await preferenciasRepositorio.definirDiasDaSemanaEscolhidos([hoje.weekday]);
    final checkinRepositorio = CheckinTreinoRepository();
    await checkinRepositorio.marcarConcluido(hoje.subtract(const Duration(days: 7)), 1);
    await checkinRepositorio.marcarConcluido(hoje.subtract(const Duration(days: 14)), 1);
    final notificador = _NotificadorFake();
    final chaveHoje = Key('checkin-dia-1-${hoje.toIso8601String().substring(0, 10)}');

    await tester.pumpWidget(
      MaterialApp(
        home: MinhaFichaView(
          anamneseRepositorio: anamneseRepositorio,
          preferenciasRepositorio: preferenciasRepositorio,
          checkinRepositorio: checkinRepositorio,
          notificadorConquistas: notificador,
        ),
      ),
    );
    await _carregar(tester);

    expect(notificador.chamadas, isEmpty);

    await _tocar(tester, find.byKey(chaveHoje));

    expect(notificador.chamadas, ['¡Racha de 3 días!']);
  });
}
