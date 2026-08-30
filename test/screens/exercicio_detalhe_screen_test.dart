import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/data/biblioteca_exercicios.dart';
import 'package:app_personal_trainer/models/exercicio.dart';
import 'package:app_personal_trainer/models/ficha_treino.dart';
import 'package:app_personal_trainer/models/registro_carga.dart';
import 'package:app_personal_trainer/screens/exercicio_detalhe_screen.dart';
import 'package:app_personal_trainer/services/treino_repository.dart';

final _flexao = bibliotecaExercicios.first;
final _semImagem = Exercicio(
  id: _flexao.id,
  nome: _flexao.nome,
  grupoMuscularPrincipal: _flexao.grupoMuscularPrincipal,
  gruposMuscularesSecundarios: _flexao.gruposMuscularesSecundarios,
  nivel: _flexao.nivel,
  objetivos: _flexao.objetivos,
  equipamento: _flexao.equipamento,
  instrucoes: _flexao.instrucoes,
);

const _lista = Key('lista-exercicio-detalhe');

// Chips + instruções + cronômetro já ocupam a viewport de teste, então o
// formulário de carga e o histórico ficam abaixo da dobra — precisamos
// rolar até o conteúdo antes de interagir com ele ou fazer qualquer
// asserção sobre ele, do contrário o finder o considera "offstage" mesmo
// já construído.
Future<void> _rolarAte(WidgetTester tester, Finder finder) =>
    tester.dragUntilVisible(finder, find.byKey(_lista), const Offset(0, -300));

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Sem histórico, mostra estado vazio', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ExercicioDetalheScreen(exercicio: _flexao)));
    await tester.pump();
    await tester.pump();
    await _rolarAte(tester, find.textContaining('Nenhum registro de carga ainda'));

    expect(find.textContaining('Nenhum registro de carga ainda'), findsOneWidget);
  });

  testWidgets('Registrar uma carga adiciona ao histórico e limpa os campos', (tester) async {
    final repositorio = TreinoRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: ExercicioDetalheScreen(exercicio: _flexao, repositorio: repositorio),
      ),
    );
    await tester.pump();
    await _rolarAte(tester, find.byKey(const Key('botao-registrar-carga')));

    await tester.enterText(find.byKey(const Key('campo-peso-carga')), '0');
    await tester.enterText(find.byKey(const Key('campo-series')), '3');
    await tester.enterText(find.byKey(const Key('campo-repeticoes')), '15');
    await tester.tap(find.byKey(const Key('botao-registrar-carga')));
    await tester.pumpAndSettle();
    await _rolarAte(tester, find.text('0.0 kg · 3x15'));

    expect(find.text('0.0 kg · 3x15'), findsOneWidget);

    final campoPeso = tester.widget<TextField>(find.byKey(const Key('campo-peso-carga')));
    expect(campoPeso.controller!.text, isEmpty);
  });

  testWidgets('Histórico só mostra registros do exercício aberto', (tester) async {
    final repositorio = TreinoRepository();
    final outroExercicio = bibliotecaExercicios[1];
    await repositorio.registrarCarga(
      RegistroCarga(
        exercicioId: outroExercicio.id,
        data: DateTime(2026, 1, 1),
        pesoKg: 10,
        series: 3,
        repeticoes: 12,
      ),
    );
    await repositorio.registrarCarga(
      RegistroCarga(
        exercicioId: _flexao.id,
        data: DateTime(2026, 1, 2),
        pesoKg: 0,
        series: 3,
        repeticoes: 15,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ExercicioDetalheScreen(exercicio: _flexao, repositorio: repositorio),
      ),
    );
    await tester.pump();
    await tester.pump();
    await _rolarAte(tester, find.byType(ListTile));

    expect(find.textContaining('Nenhum registro de carga ainda'), findsNothing);
    final tiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
    expect(tiles, hasLength(1));
  });

  testWidgets('Campos inválidos não registram nada', (tester) async {
    final repositorio = TreinoRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: ExercicioDetalheScreen(exercicio: _flexao, repositorio: repositorio),
      ),
    );
    await tester.pump();
    await _rolarAte(tester, find.byKey(const Key('botao-registrar-carga')));

    await tester.enterText(find.byKey(const Key('campo-peso-carga')), 'abc');
    await tester.tap(find.byKey(const Key('botao-registrar-carga')));
    await tester.pumpAndSettle();
    await _rolarAte(tester, find.textContaining('Nenhum registro de carga ainda'));

    expect(find.textContaining('Nenhum registro de carga ainda'), findsOneWidget);
  });

  testWidgets('Peso 0 registra normalmente (exercício de peso do corpo)', (tester) async {
    final repositorio = TreinoRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: ExercicioDetalheScreen(exercicio: _flexao, repositorio: repositorio),
      ),
    );
    await tester.pump();
    await _rolarAte(tester, find.byKey(const Key('botao-registrar-carga')));

    await tester.enterText(find.byKey(const Key('campo-peso-carga')), '0');
    await tester.enterText(find.byKey(const Key('campo-series')), '3');
    await tester.enterText(find.byKey(const Key('campo-repeticoes')), '20');
    await tester.tap(find.byKey(const Key('botao-registrar-carga')));
    await tester.pumpAndSettle();
    await _rolarAte(tester, find.text('0.0 kg · 3x20'));

    expect(find.text('0.0 kg · 3x20'), findsOneWidget);
  });

  testWidgets('Com 2+ registros, mostra o resumo de evolução de carga', (tester) async {
    final repositorio = TreinoRepository();
    await repositorio.registrarCarga(RegistroCarga(
      exercicioId: _flexao.id,
      data: DateTime.now().subtract(const Duration(days: 21)),
      pesoKg: 10,
      series: 3,
      repeticoes: 10,
    ));
    await repositorio.registrarCarga(RegistroCarga(
      exercicioId: _flexao.id,
      data: DateTime.now(),
      pesoKg: 16,
      series: 3,
      repeticoes: 10,
    ));

    await tester.pumpWidget(
      MaterialApp(
        home: ExercicioDetalheScreen(exercicio: _flexao, repositorio: repositorio),
      ),
    );
    await tester.pump();
    await tester.pump();
    await _rolarAte(tester, find.textContaining('De 10 kg para 16 kg'));

    expect(find.textContaining('De 10 kg para 16 kg'), findsOneWidget);
    expect(find.byKey(const Key('grafico-linha-simples')), findsOneWidget);
  });

  testWidgets('Registrar um novo recorde de carga mostra o aviso de destaque', (tester) async {
    final repositorio = TreinoRepository();
    await repositorio.registrarCarga(RegistroCarga(
      exercicioId: _flexao.id,
      data: DateTime.now().subtract(const Duration(days: 7)),
      pesoKg: 12,
      series: 3,
      repeticoes: 10,
    ));

    await tester.pumpWidget(
      MaterialApp(
        home: ExercicioDetalheScreen(exercicio: _flexao, repositorio: repositorio),
      ),
    );
    await tester.pump();
    await _rolarAte(tester, find.byKey(const Key('botao-registrar-carga')));

    await tester.enterText(find.byKey(const Key('campo-peso-carga')), '15');
    await tester.enterText(find.byKey(const Key('campo-series')), '3');
    await tester.enterText(find.byKey(const Key('campo-repeticoes')), '10');
    await tester.tap(find.byKey(const Key('botao-registrar-carga')));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Novo recorde neste exercício'), findsOneWidget);
  });

  testWidgets('Editar uma carga pelo menu troca os valores salvos', (tester) async {
    final repositorio = TreinoRepository();
    await repositorio.registrarCarga(RegistroCarga(
      exercicioId: _flexao.id,
      data: DateTime(2026, 1, 2),
      pesoKg: 10,
      series: 3,
      repeticoes: 12,
    ));

    await tester.pumpWidget(
      MaterialApp(home: ExercicioDetalheScreen(exercicio: _flexao, repositorio: repositorio)),
    );
    await tester.pump();
    await tester.pump();

    final registro = (await repositorio.listarCargas()).single;
    await _rolarAte(tester, find.byKey(Key('menu-carga-${registro.id}')));
    await tester.tap(find.byKey(Key('menu-carga-${registro.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('editar-campo-peso-carga')), '15');
    await tester.enterText(find.byKey(const Key('editar-campo-series')), '4');
    await tester.enterText(find.byKey(const Key('editar-campo-repeticoes')), '8');
    await tester.tap(find.byKey(const Key('editar-salvar-carga')));
    await tester.pumpAndSettle();

    final atualizado = (await repositorio.listarCargas()).single;
    expect(atualizado.id, registro.id);
    expect(atualizado.pesoKg, 15);
    expect(atualizado.series, 4);
    expect(atualizado.repeticoes, 8);
  });

  testWidgets('Apagar uma carga pelo menu pede confirmação e remove do histórico', (tester) async {
    final repositorio = TreinoRepository();
    await repositorio.registrarCarga(RegistroCarga(
      exercicioId: _flexao.id,
      data: DateTime(2026, 1, 2),
      pesoKg: 10,
      series: 3,
      repeticoes: 12,
    ));

    await tester.pumpWidget(
      MaterialApp(home: ExercicioDetalheScreen(exercicio: _flexao, repositorio: repositorio)),
    );
    await tester.pump();
    await tester.pump();

    final registro = (await repositorio.listarCargas()).single;
    await _rolarAte(tester, find.byKey(Key('menu-carga-${registro.id}')));
    await tester.tap(find.byKey(Key('menu-carga-${registro.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apagar').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmar-apagar-carga')));
    await tester.pumpAndSettle();

    expect(await repositorio.listarCargas(), isEmpty);
    await _rolarAte(tester, find.textContaining('Nenhum registro de carga ainda'));
    expect(find.textContaining('Nenhum registro de carga ainda'), findsOneWidget);
  });

  testWidgets('Mostra o cronômetro de descanso', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ExercicioDetalheScreen(exercicio: _flexao)));
    await tester.pump();
    await tester.pump();
    await _rolarAte(tester, find.byKey(const Key('texto-cronometro')));

    expect(find.text('Cronômetro de descanso'), findsOneWidget);
    expect(find.byKey(const Key('texto-cronometro')), findsOneWidget);
  });

  testWidgets('Sem imagem real, mostra a ilustração genérica do grupo muscular e o aviso', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: ExercicioDetalheScreen(exercicio: _semImagem)));
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
    expect(find.textContaining('Ilustração genérica do grupo muscular'), findsOneWidget);
  });

  testWidgets('Com imagem real, mostra a imagem e some o aviso de ilustração genérica', (
    tester,
  ) async {
    final comImagem = Exercicio(
      id: _flexao.id,
      nome: _flexao.nome,
      grupoMuscularPrincipal: _flexao.grupoMuscularPrincipal,
      gruposMuscularesSecundarios: _flexao.gruposMuscularesSecundarios,
      nivel: _flexao.nivel,
      objetivos: _flexao.objetivos,
      equipamento: _flexao.equipamento,
      instrucoes: _flexao.instrucoes,
      caminhoImagem: 'assets/exercicios/flexao-de-braco.png',
    );

    await tester.pumpWidget(MaterialApp(home: ExercicioDetalheScreen(exercicio: comImagem)));
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(SvgPicture), findsNothing);
    expect(find.textContaining('Ilustração genérica do grupo muscular'), findsNothing);
  });

  const _prescricao = PrescricaoTreino(
    series: '3 a 4 séries',
    repeticoes: '10 a 12 repetições',
    descanso: '60 a 90 segundos entre séries',
    estilo: 'Cargas moderadas com pouco descanso.',
  );

  testWidgets('Com prescrição, mostra séries/repetições/descanso no topo', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: ExercicioDetalheScreen(exercicio: _flexao, prescricao: _prescricao)),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('cartao-treino-de-hoje')), findsOneWidget);
    expect(find.text('3 a 4 séries · 10 a 12 repetições'), findsOneWidget);
    expect(find.textContaining('Descanso: 60 a 90 segundos'), findsOneWidget);
    // Sem carga registrada: orientação de como escolher o peso.
    expect(find.textContaining('as 2 últimas repetições'), findsOneWidget);
  });

  testWidgets('Com prescrição e histórico, o peso mostra a última carga', (tester) async {
    final repositorio = TreinoRepository();
    await repositorio.registrarCarga(RegistroCarga(
      exercicioId: _flexao.id,
      data: DateTime(2026, 1, 2),
      pesoKg: 12,
      series: 3,
      repeticoes: 10,
    ));

    await tester.pumpWidget(
      MaterialApp(
        home: ExercicioDetalheScreen(
          exercicio: _flexao,
          prescricao: _prescricao,
          repositorio: repositorio,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('sua última carga foi 12 kg (3x10)'), findsOneWidget);
  });

  testWidgets('Sem prescrição (aberto pela biblioteca), não mostra o cartão', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ExercicioDetalheScreen(exercicio: _flexao)));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('cartao-treino-de-hoje')), findsNothing);
  });

  testWidgets('Tocar na imagem abre a visualização ampliada com zoom', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ExercicioDetalheScreen(exercicio: _semImagem)));
    await tester.pump();

    expect(find.text('Toque para ampliar'), findsOneWidget);

    await tester.tap(find.byKey(const Key('imagem-exercicio-tocavel')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('imagem-ampliada')), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);

    await tester.tap(find.byKey(const Key('fechar-imagem-ampliada')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('imagem-ampliada')), findsNothing);
  });
}
