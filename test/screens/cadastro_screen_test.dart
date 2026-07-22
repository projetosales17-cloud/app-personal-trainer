import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/screens/cadastro_screen.dart';
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

  testWidgets('Botão fica desabilitado até o formulário ser preenchido corretamente', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CadastroScreen(
          authRepositorio: AuthRepository(auth: MockFirebaseAuth()),
          sessaoUnicaService: SessaoUnicaService(controleSessao: _ControleSessaoFake()),
        ),
      ),
    );

    expect(
      tester.widget<FilledButton>(find.byKey(const Key('botao-cadastrar'))).onPressed,
      isNull,
    );

    await tester.enterText(find.byKey(const Key('campo-email-cadastro')), 'nova@example.com');
    await tester.enterText(find.byKey(const Key('campo-senha-cadastro')), 'senha123');
    await tester.enterText(
      find.byKey(const Key('campo-confirmar-senha-cadastro')),
      'senha123',
    );
    await tester.pump();

    // Ainda falta aceitar os termos.
    expect(
      tester.widget<FilledButton>(find.byKey(const Key('botao-cadastrar'))).onPressed,
      isNull,
    );

    await tester.tap(find.byKey(const Key('checkbox-termos-cadastro')));
    await tester.pump();

    expect(
      tester.widget<FilledButton>(find.byKey(const Key('botao-cadastrar'))).onPressed,
      isNotNull,
    );
  });

  testWidgets('Senhas diferentes mantêm o botão desabilitado', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CadastroScreen(
          authRepositorio: AuthRepository(auth: MockFirebaseAuth()),
          sessaoUnicaService: SessaoUnicaService(controleSessao: _ControleSessaoFake()),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('campo-email-cadastro')), 'nova@example.com');
    await tester.enterText(find.byKey(const Key('campo-senha-cadastro')), 'senha123');
    await tester.enterText(
      find.byKey(const Key('campo-confirmar-senha-cadastro')),
      'outrasenha',
    );
    await tester.tap(find.byKey(const Key('checkbox-termos-cadastro')));
    await tester.pump();

    expect(
      tester.widget<FilledButton>(find.byKey(const Key('botao-cadastrar'))).onPressed,
      isNull,
    );
  });

  testWidgets('Cadastro com sucesso registra a sessão', (tester) async {
    final mockAuth = MockFirebaseAuth();
    final controleSessaoFake = _ControleSessaoFake();

    await tester.pumpWidget(
      MaterialApp(
        home: CadastroScreen(
          authRepositorio: AuthRepository(auth: mockAuth),
          sessaoUnicaService: SessaoUnicaService(controleSessao: controleSessaoFake),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('campo-email-cadastro')), 'nova@example.com');
    await tester.enterText(find.byKey(const Key('campo-senha-cadastro')), 'senha123');
    await tester.enterText(
      find.byKey(const Key('campo-confirmar-senha-cadastro')),
      'senha123',
    );
    await tester.tap(find.byKey(const Key('checkbox-termos-cadastro')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('botao-cadastrar')));
    await tester.pumpAndSettle();

    expect(mockAuth.currentUser, isNotNull);
    expect(controleSessaoFake.ultimoUidRegistrado, isNotNull);
  });

  testWidgets('Erro de cadastro mostra a mensagem traduzida', (tester) async {
    final mockAuth = MockFirebaseAuth();
    whenCalling(Invocation.method(#createUserWithEmailAndPassword, null))
        .on(mockAuth)
        .thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

    await tester.pumpWidget(
      MaterialApp(
        home: CadastroScreen(
          authRepositorio: AuthRepository(auth: mockAuth),
          sessaoUnicaService: SessaoUnicaService(controleSessao: _ControleSessaoFake()),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('campo-email-cadastro')), 'ja@existe.com');
    await tester.enterText(find.byKey(const Key('campo-senha-cadastro')), 'senha123');
    await tester.enterText(
      find.byKey(const Key('campo-confirmar-senha-cadastro')),
      'senha123',
    );
    await tester.tap(find.byKey(const Key('checkbox-termos-cadastro')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('botao-cadastrar')));
    await tester.pumpAndSettle();

    expect(find.text('Este e-mail já está cadastrado.'), findsOneWidget);
  });
}
