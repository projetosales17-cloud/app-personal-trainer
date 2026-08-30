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

    expect(find.textContaining('Completa la anamnesis'), findsOneWidget);
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

    expect(find.text('¡Hola!'), findsOneWidget);
    expect(find.text('Entrenamiento del día'), findsOneWidget);
    // Misma cuenta de semana/fase que la pestaña Mi rutina (bloque 1 = adaptación).
    expect(find.text('Semana 1 · Bloque de adaptación'), findsOneWidget);
    expect(find.textContaining('Rutina válida hasta'), findsOneWidget);
    expect(find.text('Alimentación del día'), findsOneWidget);
    expect(find.text('Almuerzo'), findsOneWidget);
    expect(find.textContaining('comidas · míralas en la pestaña Alimentación'), findsOneWidget);
    expect(find.textContaining('Menú válido hasta'), findsOneWidget);
    expect(find.text('Progreso'), findsOneWidget);
    expect(find.text('65.0 kg'), findsOneWidget);
    expect(
      find.text('Registra tu peso en la pestaña Progreso para seguir tu evolución.'),
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
    expect(find.text('¡Hola, Maria!'), findsOneWidget);

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

    expect(find.text('¡Hola, Ana!'), findsOneWidget);
    expect(find.text('¡Hola, Maria!'), findsNothing);
  });

  testWidgets('Mostra o avatar da usuária ao lado da saudação', (tester) async {
    final repositorio = AnamneseRepository();
    await repositorio.salvar(
      const Anamnese(
        nome: 'Maria Silva',
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

    expect(find.byKey(const Key('avatar-perfil-iniciais')), findsOneWidget);
    expect(find.text('MS'), findsOneWidget);
  });
}
