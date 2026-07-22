import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/screens/login_screen.dart';
import 'package:app_personal_trainer/services/auth_repository.dart';
import 'package:app_personal_trainer/services/controle_sessao.dart';
import 'package:app_personal_trainer/services/sessao_unica_service.dart';

class _ControleSessaoFake implements ControleSessao {
  String? ultimoUidRegistrado;

  @override
  String gerarTokenSessao() => 'token-fake';

  @override
  Future<void> registrarSessao(String uid, String tokenSessao) async {
    ultimoUidRegistrado = uid;
  }

  @override
  Stream<String?> observarTokenSessao(String uid) => const Stream.empty();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Entrar com sucesso registra a sessão', (tester) async {
    final mockAuth = MockFirebaseAuth(
      mockUser: MockUser(uid: 'uid-1', email: 'usuaria@example.com'),
    );
    final controleSessaoFake = _ControleSessaoFake();

    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          authRepositorio: AuthRepository(auth: mockAuth),
          sessaoUnicaService: SessaoUnicaService(controleSessao: controleSessaoFake),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('campo-email-login')), 'usuaria@example.com');
    await tester.enterText(find.byKey(const Key('campo-senha-login')), 'senha123');
    await tester.tap(find.byKey(const Key('botao-entrar')));
    await tester.pumpAndSettle();

    expect(mockAuth.currentUser, isNotNull);
    expect(controleSessaoFake.ultimoUidRegistrado, 'uid-1');
  });

  testWidgets('Erro de login mostra a mensagem traduzida', (tester) async {
    final mockAuth = MockFirebaseAuth();
    whenCalling(Invocation.method(#signInWithEmailAndPassword, null))
        .on(mockAuth)
        .thenThrow(FirebaseAuthException(code: 'wrong-password'));

    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          authRepositorio: AuthRepository(auth: mockAuth),
          sessaoUnicaService: SessaoUnicaService(controleSessao: _ControleSessaoFake()),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('campo-email-login')), 'a@a.com');
    await tester.enterText(find.byKey(const Key('campo-senha-login')), 'errada');
    await tester.tap(find.byKey(const Key('botao-entrar')));
    await tester.pumpAndSettle();

    expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
  });

  testWidgets('Esqueci minha senha sem e-mail preenchido mostra aviso', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          authRepositorio: AuthRepository(auth: MockFirebaseAuth()),
          sessaoUnicaService: SessaoUnicaService(controleSessao: _ControleSessaoFake()),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('botao-esqueci-senha')));
    await tester.pump();

    expect(find.text('Digite seu e-mail para redefinir a senha.'), findsOneWidget);
  });

  testWidgets('Esqueci minha senha com e-mail preenchido mostra confirmação', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          authRepositorio: AuthRepository(auth: MockFirebaseAuth()),
          sessaoUnicaService: SessaoUnicaService(controleSessao: _ControleSessaoFake()),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('campo-email-login')), 'a@a.com');
    await tester.tap(find.byKey(const Key('botao-esqueci-senha')));
    await tester.pumpAndSettle();

    expect(find.text('E-mail de redefinição de senha enviado.'), findsOneWidget);
  });

  testWidgets('Tocar em "Cadastre-se" abre a tela de cadastro', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          authRepositorio: AuthRepository(auth: MockFirebaseAuth()),
          sessaoUnicaService: SessaoUnicaService(controleSessao: _ControleSessaoFake()),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('botao-ir-para-cadastro')));
    await tester.pumpAndSettle();

    // "Criar conta" aparece tanto no título da AppBar quanto no botão.
    expect(find.text('Criar conta'), findsWidgets);
  });
}
