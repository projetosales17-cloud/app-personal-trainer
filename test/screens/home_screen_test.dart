import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/models/anamnese.dart';
import 'package:app_personal_trainer/screens/home_screen.dart';
import 'package:app_personal_trainer/services/anamnese_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Sem anamnese salva, pede para completar o onboarding', (tester) async {
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Complete a anamnese'), findsOneWidget);
  });

  testWidgets('Com anamnese salva, mostra o card de treino do dia', (tester) async {
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
      MaterialApp(home: HomeScreen(anamneseRepositorio: repositorio)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Olá!'), findsOneWidget);
    expect(find.text('Treino do dia'), findsOneWidget);
    // Mesma contagem de semana/fase da aba Minha ficha (bloco 1 = adaptação).
    expect(find.text('Semana 1 · Bloco de adaptação'), findsOneWidget);
    expect(find.textContaining('Ficha válida até'), findsOneWidget);
    expect(find.text('Alimentação do dia'), findsOneWidget);
    expect(find.text('Almoço'), findsOneWidget);
    expect(find.textContaining('refeições · veja na aba Alimentação'), findsOneWidget);
    expect(find.textContaining('Cardápio válido até'), findsOneWidget);
    expect(find.text('Progresso'), findsOneWidget);
    expect(find.text('65.0 kg'), findsOneWidget);
    expect(
      find.text('Registre seu peso na aba Progresso para acompanhar a evolução.'),
      findsOneWidget,
    );
  });

  testWidgets('Editar a anamnese (mesma sessão) atualiza a saudação da Home', (tester) async {
    final repositorio = AnamneseRepository();
    await repositorio.salvar(
      const Anamnese(
        nome: 'Maria',
        idade: 30,
        alturaCm: 170,
        pesoAtualKg: 65,
        objetivoPrincipal: Objetivo.hipertrofia,
        nivelAtividade: NivelAtividade.moderado,
        frequenciaSemanalDias: 3,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(anamneseRepositorio: repositorio)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Olá, Maria!'), findsOneWidget);

    await repositorio.salvar(
      const Anamnese(
        nome: 'Ana',
        idade: 30,
        alturaCm: 170,
        pesoAtualKg: 65,
        objetivoPrincipal: Objetivo.hipertrofia,
        nivelAtividade: NivelAtividade.moderado,
        frequenciaSemanalDias: 3,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Olá, Ana!'), findsOneWidget);
    expect(find.text('Olá, Maria!'), findsNothing);
  });
}
