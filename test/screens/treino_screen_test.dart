import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/models/anamnese.dart';
import 'package:app_personal_trainer/screens/treino_screen.dart';
import 'package:app_personal_trainer/services/anamnese_repository.dart';

const _lista = Key('lista-exercicios');

Future<void> _abrirBiblioteca(WidgetTester tester) async {
  await tester.tap(find.text('Biblioteca'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('A aba "Minha ficha" é a primeira mostrada', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TreinoScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Complete a anamnese'), findsOneWidget);
  });

  testWidgets('Na Biblioteca, mostra o primeiro exercício da lista por padrão', (tester) async {
    await tester.pumpWidget(MaterialApp(home: TreinoScreen()));
    await _abrirBiblioteca(tester);

    expect(find.text('Flexão de braço'), findsOneWidget);
  });

  testWidgets('É possível rolar até exercícios mais abaixo na lista', (tester) async {
    await tester.pumpWidget(MaterialApp(home: TreinoScreen()));
    await _abrirBiblioteca(tester);

    await tester.dragUntilVisible(
      find.text('Prancha'),
      find.byKey(_lista),
      const Offset(0, -300),
    );

    expect(find.text('Prancha'), findsOneWidget);
  });

  testWidgets('Filtrar por grupo muscular mostra só os exercícios daquele grupo', (tester) async {
    await tester.pumpWidget(MaterialApp(home: TreinoScreen()));
    await _abrirBiblioteca(tester);

    // Rola a lista horizontal de filtros o suficiente para o chip "Glúteo"
    // ficar bem dentro da área visível (não só na borda do cache extent).
    await tester.drag(find.byKey(const Key('filtro-grupos')), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Glúteo'));
    await tester.pumpAndSettle();

    expect(find.text('Elevação pélvica'), findsOneWidget);
    expect(find.text('Flexão de braço'), findsNothing);
  });

  testWidgets('Tocar em um exercício abre a tela de detalhe', (tester) async {
    await tester.pumpWidget(MaterialApp(home: TreinoScreen()));
    await _abrirBiblioteca(tester);

    await tester.tap(find.text('Flexão de braço'));
    await tester.pumpAndSettle();

    expect(find.text('Como executar'), findsOneWidget);
    expect(find.textContaining('largura dos ombros'), findsOneWidget);
  });

  testWidgets(
    'Com treino em casa, a Biblioteca já vem filtrada sem equipamento de academia',
    (tester) async {
      final anamneseRepositorio = AnamneseRepository();
      await anamneseRepositorio.salvar(
        const Anamnese(
          idade: 30,
          alturaCm: 170,
          pesoAtualKg: 65,
          objetivoPrincipal: Objetivo.tonificacao,
          nivelAtividade: NivelAtividade.moderado,
          frequenciaSemanalDias: 3,
          localTreino: LocalTreino.casa,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(home: TreinoScreen(anamneseRepositorio: anamneseRepositorio)),
      );
      await _abrirBiblioteca(tester);
      await tester.pumpAndSettle();

      expect(tester.widget<FilterChip>(find.byKey(const Key('filtro-so-casa'))).selected, isTrue);
      // Supino com barra depende de equipamento de academia — fica escondido.
      expect(find.text('Supino reto com barra'), findsNothing);
      expect(find.text('Flexão de braço'), findsOneWidget);

      // Desligando o filtro, o exercício de barra reaparece.
      await tester.tap(find.byKey(const Key('filtro-so-casa')));
      await tester.pumpAndSettle();
      expect(find.text('Supino reto com barra'), findsOneWidget);
    },
  );
}
