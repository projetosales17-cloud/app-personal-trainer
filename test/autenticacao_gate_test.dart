import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/autenticacao_gate.dart';
import 'package:app_personal_trainer/services/assinatura_repository.dart';
import 'package:app_personal_trainer/services/auth_repository.dart';
import 'package:app_personal_trainer/services/controle_sessao.dart';
import 'package:app_personal_trainer/services/sessao_unica_service.dart';
import 'package:app_personal_trainer/services/sincronizador_dados.dart';

class _ControleSessaoFake implements ControleSessao {
  _ControleSessaoFake({String? tokenInicial}) : _tokenAtual = tokenInicial;

  final _controller = StreamController<String?>.broadcast();
  String? _tokenAtual;

  @override
  String gerarTokenSessao() => 'token-gerado';

  @override
  Future<void> registrarSessao(String uid, String tokenSessao) async {
    _tokenAtual = tokenSessao;
    _controller.add(tokenSessao);
  }

  @override
  Stream<String?> observarTokenSessao(String uid) async* {
    // Como o Firestore: entrega o valor atual do documento ao se inscrever
    // e depois as mudanças.
    yield _tokenAtual;
    yield* _controller.stream;
  }

  void emitir(String? token) {
    _tokenAtual = token;
    _controller.add(token);
  }
}

class _AssinaturaSempreAtiva implements AssinaturaRepository {
  @override
  Stream<bool> observarAssinaturaAtiva(String uid) => Stream.value(true);
}

class _AssinaturaControlavel implements AssinaturaRepository {
  final _controller = StreamController<bool>.broadcast();

  @override
  Stream<bool> observarAssinaturaAtiva(String uid) => _controller.stream;

  void emitir(bool ativa) => _controller.add(ativa);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Sem login, mostra a tela de entrar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AutenticacaoGate(
          authRepositorio: AuthRepository(auth: MockFirebaseAuth()),
          sessaoUnicaService: SessaoUnicaService(controleSessao: _ControleSessaoFake()),
          assinaturaRepositorio: _AssinaturaSempreAtiva(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Entrar'), findsWidgets);
  });

  testWidgets('Logada com assinatura ativa, mostra o restante do app (onboarding)', (
    tester,
  ) async {
    final authRepositorio = AuthRepository(
      auth: MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'uid-1', email: 'usuaria@example.com'),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AutenticacaoGate(
          authRepositorio: authRepositorio,
          sessaoUnicaService: SessaoUnicaService(controleSessao: _ControleSessaoFake()),
          assinaturaRepositorio: _AssinaturaSempreAtiva(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bem-vinda!'), findsOneWidget);
  });

  testWidgets('Logada sem assinatura ativa, mostra a tela de assinatura necessária', (
    tester,
  ) async {
    final authRepositorio = AuthRepository(
      auth: MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'uid-1', email: 'usuaria@example.com'),
      ),
    );

    final assinaturaFake = _AssinaturaControlavel();
    await tester.pumpWidget(
      MaterialApp(
        home: AutenticacaoGate(
          authRepositorio: authRepositorio,
          sessaoUnicaService: SessaoUnicaService(controleSessao: _ControleSessaoFake()),
          assinaturaRepositorio: assinaturaFake,
        ),
      ),
    );
    await tester.pump();
    assinaturaFake.emitir(false);
    await tester.pumpAndSettle();

    expect(find.text('Você precisa de uma assinatura ativa'), findsOneWidget);
    expect(find.text('Bem-vinda!'), findsNothing);
  });

  testWidgets(
    'Assinatura liberada enquanto a usuária está na tela de bloqueio avança sozinha',
    (tester) async {
      final authRepositorio = AuthRepository(
        auth: MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'uid-1', email: 'usuaria@example.com'),
        ),
      );
      final assinaturaFake = _AssinaturaControlavel();

      await tester.pumpWidget(
        MaterialApp(
          home: AutenticacaoGate(
            authRepositorio: authRepositorio,
            sessaoUnicaService: SessaoUnicaService(controleSessao: _ControleSessaoFake()),
            assinaturaRepositorio: assinaturaFake,
          ),
        ),
      );
      await tester.pump();
      assinaturaFake.emitir(false);
      await tester.pumpAndSettle();

      expect(find.text('Você precisa de uma assinatura ativa'), findsOneWidget);

      assinaturaFake.emitir(true);
      await tester.pumpAndSettle();

      expect(find.text('Bem-vinda!'), findsOneWidget);
    },
  );

  testWidgets(
    'Sessão substituída por outro aparelho força saída e mostra aviso',
    (tester) async {
      SharedPreferences.setMockInitialValues({'token_sessao_local': 'token-deste-aparelho'});
      final mockAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'uid-1', email: 'usuaria@example.com'),
      );
      // O Firestore já tem o token desta instalação (sessão registrada no
      // login anterior) — é o que a vigilância precisa ver antes de
      // considerar uma troca como "outro aparelho".
      final controleSessaoFake = _ControleSessaoFake(tokenInicial: 'token-deste-aparelho');

      await tester.pumpWidget(
        MaterialApp(
          home: AutenticacaoGate(
            authRepositorio: AuthRepository(auth: mockAuth),
            sessaoUnicaService: SessaoUnicaService(controleSessao: controleSessaoFake),
            assinaturaRepositorio: _AssinaturaSempreAtiva(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Simula outro aparelho entrando na mesma conta e registrando um
      // token de sessão diferente do que este aparelho tem salvo localmente.
      controleSessaoFake.emitir('token-de-outro-aparelho');
      await tester.pumpAndSettle();

      expect(mockAuth.currentUser, isNull);
      expect(find.textContaining('acessada em outro aparelho'), findsOneWidget);
      expect(find.text('Entrar'), findsWidgets);
    },
  );

  testWidgets(
    'No login, baixa a anamnese que estava só no Firestore (aparelho novo)',
    (tester) async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('usuarios').doc('uid-1').set({
        'anamnese':
            '{"idade":30,"alturaCm":170.0,"pesoAtualKg":65.0,"pesoDesejadoKg":null,'
            '"objetivoPrincipal":"emagrecimento","cirurgiaBariatrica":false,'
            '"tipoCirurgiaBariatrica":null,"mesesDesdeCirurgia":null,'
            '"condicaoHormonal":"Nenhuma","restricoesAlimentares":[],"lesoesLimitacoes":[],'
            '"nivelAtividade":"moderado","frequenciaSemanalDias":3,"regioesPriorizadas":[]}',
        'anamnese__ts': 2000,
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AutenticacaoGate(
            authRepositorio: AuthRepository(
              auth: MockFirebaseAuth(
                signedIn: true,
                mockUser: MockUser(uid: 'uid-1', email: 'usuaria@example.com'),
              ),
            ),
            sessaoUnicaService: SessaoUnicaService(controleSessao: _ControleSessaoFake()),
            assinaturaRepositorio: _AssinaturaSempreAtiva(),
            sincronizador: SincronizadorDados(firestore: firestore),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Como a anamnese desceu do servidor, o app vai direto pra navegação
      // principal em vez do onboarding.
      expect(find.text('Início'), findsWidgets);
      expect(find.text('Bem-vinda!'), findsNothing);
    },
  );
}
