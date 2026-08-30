import 'dart:convert';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/models/anamnese.dart';
import 'package:app_personal_trainer/screens/perfil_screen.dart';
import 'package:app_personal_trainer/services/agendador_notificacoes.dart';
import 'package:app_personal_trainer/services/anamnese_repository.dart';
import 'package:app_personal_trainer/services/auth_repository.dart';
import 'package:app_personal_trainer/services/foto_perfil_repository.dart';
import 'package:app_personal_trainer/services/notificacoes_treino_service.dart';
import 'package:app_personal_trainer/services/preferencias_repository.dart';

class _AgendadorFake implements AgendadorNotificacoes {
  bool permissaoConcedida = true;
  List<DateTime>? ultimasDatasAgendadas;
  bool cancelarTodosChamado = false;

  @override
  Future<bool> solicitarPermissao() async => permissaoConcedida;

  @override
  Future<void> agendarLembretesDeTreino(List<DateTime> datas) async {
    ultimasDatasAgendadas = datas;
  }

  @override
  Future<void> cancelarTodos() async {
    cancelarTodosChamado = true;
  }
}

AuthRepository _authComUsuaria({String email = 'usuaria@example.com'}) => AuthRepository(
  auth: MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'uid-1', email: email)),
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FotoPerfilRepository.atual.value = null;
  });

  testWidgets('Sem anamnese salva, pede para completar o onboarding', (tester) async {
    await tester.pumpWidget(MaterialApp(home: PerfilScreen(authRepositorio: _authComUsuaria())));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Completa la anamnesis'), findsOneWidget);
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
      MaterialApp(
        home: PerfilScreen(
          anamneseRepositorio: anamneseRepositorio,
          authRepositorio: _authComUsuaria(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('30 años'), findsOneWidget);
    expect(find.text('170 cm'), findsOneWidget);
    expect(find.text('65.0 kg'), findsOneWidget);
    expect(find.text('60.0 kg'), findsOneWidget);
    expect(find.text('Bajar de peso y perder medidas'), findsOneWidget);
    expect(find.text('Menopausa'), findsOneWidget);
    expect(find.text('Lactose'), findsOneWidget);
  });

  testWidgets('Botão "Editar mis datos" abre o fluxo pré-preenchido', (tester) async {
    final anamneseRepositorio = AnamneseRepository();
    await anamneseRepositorio.salvar(
      const Anamnese(
        nome: 'Lucía',
        idade: 42,
        alturaCm: 168,
        pesoAtualKg: 70,
        objetivoPrincipal: Objetivo.tonificacao,
        nivelAtividade: NivelAtividade.leve,
        frequenciaSemanalDias: 3,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PerfilScreen(
          anamneseRepositorio: anamneseRepositorio,
          authRepositorio: _authComUsuaria(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byKey(const Key('botao-editar-anamnese')));
    await tester.pumpAndSettle();

    expect(find.text('Editar mis datos'), findsOneWidget);
    // Abre na etapa de nome, já preenchida.
    expect(
      tester.widget<TextField>(find.byKey(const Key('campo-nome-onboarding'))).controller!.text,
      'Lucía',
    );
  });

  testWidgets('Mostra o e-mail da conta logada', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PerfilScreen(authRepositorio: _authComUsuaria(email: 'maria@example.com')),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('maria@example.com'), findsOneWidget);
  });

  testWidgets('Tocar em "Sair da conta" chama o signOut', (tester) async {
    final mockAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'uid-1', email: 'usuaria@example.com'),
    );
    await tester.pumpWidget(
      MaterialApp(home: PerfilScreen(authRepositorio: AuthRepository(auth: mockAuth))),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byKey(const Key('botao-sair')));
    await tester.pump();

    expect(mockAuth.currentUser, isNull);
  });

  testWidgets('Alternar o switch de notificações persiste a preferência', (tester) async {
    final preferenciasRepositorio = PreferenciasRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: PerfilScreen(
          authRepositorio: _authComUsuaria(),
          preferenciasRepositorio: preferenciasRepositorio,
          notificacoesService: NotificacoesTreinoService(
            agendador: _AgendadorFake(),
            preferenciasRepositorio: preferenciasRepositorio,
          ),
        ),
      ),
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

  testWidgets(
    'Ligar notificações com anamnese salva agenda lembretes de treino',
    (tester) async {
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
      final agendador = _AgendadorFake();
      final preferenciasRepositorio = PreferenciasRepository();
      await preferenciasRepositorio.definirNotificacoesAtivadas(false);

      await tester.pumpWidget(
        MaterialApp(
          home: PerfilScreen(
            authRepositorio: _authComUsuaria(),
            anamneseRepositorio: anamneseRepositorio,
            preferenciasRepositorio: preferenciasRepositorio,
            notificacoesService: NotificacoesTreinoService(
              agendador: agendador,
              preferenciasRepositorio: preferenciasRepositorio,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      await tester.scrollUntilVisible(find.byKey(const Key('switch-notificacoes')), 200);
      await tester.tap(find.byKey(const Key('switch-notificacoes')));
      await tester.pumpAndSettle();

      expect(agendador.ultimasDatasAgendadas, isNotNull);
      expect(agendador.ultimasDatasAgendadas, isNotEmpty);
      expect(await preferenciasRepositorio.notificacoesAtivadas(), isTrue);
      expect(
        tester.widget<SwitchListTile>(find.byKey(const Key('switch-notificacoes'))).value,
        isTrue,
      );
    },
  );

  testWidgets(
    'Permissão negada mostra aviso e mantém a preferência desligada',
    (tester) async {
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
      final agendador = _AgendadorFake()..permissaoConcedida = false;
      final preferenciasRepositorio = PreferenciasRepository();
      await preferenciasRepositorio.definirNotificacoesAtivadas(false);

      await tester.pumpWidget(
        MaterialApp(
          home: PerfilScreen(
            authRepositorio: _authComUsuaria(),
            anamneseRepositorio: anamneseRepositorio,
            preferenciasRepositorio: preferenciasRepositorio,
            notificacoesService: NotificacoesTreinoService(
              agendador: agendador,
              preferenciasRepositorio: preferenciasRepositorio,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      await tester.scrollUntilVisible(find.byKey(const Key('switch-notificacoes')), 200);
      await tester.tap(find.byKey(const Key('switch-notificacoes')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Permiso de notificaciones denegado'), findsOneWidget);
      expect(await preferenciasRepositorio.notificacoesAtivadas(), isFalse);
      expect(
        tester.widget<SwitchListTile>(find.byKey(const Key('switch-notificacoes'))).value,
        isFalse,
      );
    },
  );

  testWidgets('Mostra avisos de assinatura e suporte ainda pendentes', (tester) async {
    await tester.pumpWidget(MaterialApp(home: PerfilScreen(authRepositorio: _authComUsuaria())));
    await tester.pump();
    await tester.pump();

    expect(
      find.textContaining('cobro de la suscripción todavía no', skipOffstage: false),
      findsOneWidget,
    );
    // "Suporte" fica abaixo da dobra na viewport de teste (a nova seção
    // "Conta" empurrou o conteúdo) — usamos skipOffstage:false, já
    // construído com o texto certo, só não visível sem rolar.
    expect(
      find.textContaining('Canal de soporte próximamente', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('Sem foto de perfil, o topo mostra as iniciais e "Agregar foto"', (tester) async {
    final anamneseRepositorio = AnamneseRepository();
    await anamneseRepositorio.salvar(
      const Anamnese(
        nome: 'Bianca Reis',
        idade: 30,
        alturaCm: 170,
        pesoAtualKg: 65,
        objetivoPrincipal: Objetivo.hipertrofia,
        nivelAtividade: NivelAtividade.moderado,
        frequenciaSemanalDias: 3,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: PerfilScreen(
          authRepositorio: _authComUsuaria(),
          anamneseRepositorio: anamneseRepositorio,
          fotoPerfilRepositorio: FotoPerfilRepository(
            firestore: FakeFirebaseFirestore(),
            uidAtual: () => 'uid-1',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('avatar-perfil-iniciais')), findsOneWidget);
    expect(find.text('BR'), findsOneWidget);
    expect(find.text('Agregar foto'), findsOneWidget);
  });

  testWidgets('Elegir una foto de la galería la guarda y muestra el avatar con la imagen', (
    tester,
  ) async {
    final anamneseRepositorio = AnamneseRepository();
    await anamneseRepositorio.salvar(
      const Anamnese(
        nome: 'Bianca',
        idade: 30,
        alturaCm: 170,
        pesoAtualKg: 65,
        objetivoPrincipal: Objetivo.hipertrofia,
        nivelAtividade: NivelAtividade.moderado,
        frequenciaSemanalDias: 3,
      ),
    );
    final fotoRepositorio = FotoPerfilRepository(
      firestore: FakeFirebaseFirestore(),
      uidAtual: () => 'uid-1',
    );
    // PNG 1x1 válido — MemoryImage precisa decodificar.
    final bytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PerfilScreen(
          authRepositorio: _authComUsuaria(),
          anamneseRepositorio: anamneseRepositorio,
          fotoPerfilRepositorio: fotoRepositorio,
          selecionarImagem: (_) async => bytes,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('botao-trocar-foto-perfil')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('foto-perfil-galeria')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('avatar-perfil-foto')), findsOneWidget);
    expect(await fotoRepositorio.carregar(), isNotNull);
  });
}
