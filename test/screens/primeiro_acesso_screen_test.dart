import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/screens/primeiro_acesso_screen.dart';
import 'package:app_personal_trainer/services/auth_repository.dart';
import 'package:app_personal_trainer/services/controle_sessao.dart';
import 'package:app_personal_trainer/services/primeiro_acesso_repository.dart';
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

class _FakePrimeiroAcessoRepo extends PrimeiroAcessoRepository {
  _FakePrimeiroAcessoRepo({this.erro}) : super(endpoint: Uri.parse('https://x.test'));

  final String? erro;
  Map<String, String>? chamada;

  @override
  Future<void> definirSenha({
    required String email,
    required String codigo,
    required String senha,
  }) async {
    chamada = {'email': email, 'codigo': codigo, 'senha': senha};
    if (erro != null) throw PrimeiroAcessoException(erro!);
  }
}

Widget _tela({
  required PrimeiroAcessoRepository repo,
  required AuthRepository auth,
  required SessaoUnicaService sessao,
  String? emailInicial,
  String? codigoInicial,
}) {
  return MaterialApp(
    home: PrimeiroAcessoScreen(
      authRepositorio: auth,
      sessaoUnicaService: sessao,
      primeiroAcessoRepositorio: repo,
      emailInicial: emailInicial,
      codigoInicial: codigoInicial,
    ),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('pré-preenche e-mail e código quando vêm do link', (tester) async {
    await tester.pumpWidget(_tela(
      repo: _FakePrimeiroAcessoRepo(),
      auth: AuthRepository(auth: MockFirebaseAuth()),
      sessao: SessaoUnicaService(controleSessao: _ControleSessaoFake()),
      emailInicial: 'nova@hotmail.com',
      codigoInicial: 'HP99',
    ));

    expect(
      tester.widget<TextField>(find.byKey(const Key('campo-email-primeiro-acesso'))).controller!.text,
      'nova@hotmail.com',
    );
    expect(
      tester.widget<TextField>(find.byKey(const Key('campo-codigo-primeiro-acesso'))).controller!.text,
      'HP99',
    );
  });

  testWidgets('sucesso: chama o backend, define a senha e faz login', (tester) async {
    final repo = _FakePrimeiroAcessoRepo();
    final auth = MockFirebaseAuth();
    final controle = _ControleSessaoFake();

    await tester.pumpWidget(_tela(
      repo: repo,
      auth: AuthRepository(auth: auth),
      sessao: SessaoUnicaService(controleSessao: controle),
      emailInicial: 'nova@hotmail.com',
      codigoInicial: 'HP99',
    ));

    await tester.enterText(find.byKey(const Key('campo-senha-primeiro-acesso')), 'senhaBoa1');
    await tester.enterText(find.byKey(const Key('campo-confirma-primeiro-acesso')), 'senhaBoa1');
    await tester.tap(find.byKey(const Key('botao-criar-senha-primeiro-acesso')));
    await tester.pumpAndSettle();

    expect(repo.chamada, {'email': 'nova@hotmail.com', 'codigo': 'HP99', 'senha': 'senhaBoa1'});
    expect(auth.currentUser, isNotNull);
    expect(controle.ultimoUidRegistrado, isNotNull);
  });

  testWidgets('senhas diferentes: nem chega a chamar o backend', (tester) async {
    final repo = _FakePrimeiroAcessoRepo();
    await tester.pumpWidget(_tela(
      repo: repo,
      auth: AuthRepository(auth: MockFirebaseAuth()),
      sessao: SessaoUnicaService(controleSessao: _ControleSessaoFake()),
      emailInicial: 'nova@hotmail.com',
      codigoInicial: 'HP99',
    ));

    await tester.enterText(find.byKey(const Key('campo-senha-primeiro-acesso')), 'senhaBoa1');
    await tester.enterText(find.byKey(const Key('campo-confirma-primeiro-acesso')), 'outra');
    await tester.tap(find.byKey(const Key('botao-criar-senha-primeiro-acesso')));
    await tester.pump();

    expect(find.text('As duas senhas não são iguais.'), findsOneWidget);
    expect(repo.chamada, isNull);
  });

  testWidgets('erro do backend aparece na tela', (tester) async {
    final repo = _FakePrimeiroAcessoRepo(erro: 'Código não confere.');
    await tester.pumpWidget(_tela(
      repo: repo,
      auth: AuthRepository(auth: MockFirebaseAuth()),
      sessao: SessaoUnicaService(controleSessao: _ControleSessaoFake()),
      emailInicial: 'nova@hotmail.com',
      codigoInicial: 'HP99',
    ));

    await tester.enterText(find.byKey(const Key('campo-senha-primeiro-acesso')), 'senhaBoa1');
    await tester.enterText(find.byKey(const Key('campo-confirma-primeiro-acesso')), 'senhaBoa1');
    await tester.tap(find.byKey(const Key('botao-criar-senha-primeiro-acesso')));
    await tester.pumpAndSettle();

    expect(find.text('Código não confere.'), findsOneWidget);
  });
}
