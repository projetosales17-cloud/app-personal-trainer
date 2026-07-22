import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/services/auth_repository.dart';

void main() {
  group('mensagemDeErroAuth', () {
    test('traduz códigos conhecidos', () {
      expect(mensagemDeErroAuth('email-already-in-use'), 'Este e-mail já está cadastrado.');
      expect(
        mensagemDeErroAuth('weak-password'),
        'A senha precisa ter pelo menos 6 caracteres.',
      );
      expect(mensagemDeErroAuth('invalid-email'), 'E-mail inválido.');
      expect(mensagemDeErroAuth('user-not-found'), 'E-mail ou senha incorretos.');
      expect(mensagemDeErroAuth('wrong-password'), 'E-mail ou senha incorretos.');
      expect(mensagemDeErroAuth('invalid-credential'), 'E-mail ou senha incorretos.');
    });

    test('usa mensagem genérica para código desconhecido', () {
      expect(
        mensagemDeErroAuth('algum-codigo-novo-da-api'),
        'Não foi possível completar a operação. Tente novamente.',
      );
    });
  });

  group('AuthRepository', () {
    test('usuarioAtual é nulo quando ninguém entrou', () {
      final repositorio = AuthRepository(auth: MockFirebaseAuth());
      expect(repositorio.usuarioAtual, isNull);
    });

    test('cadastrar autentica a usuária', () async {
      final repositorio = AuthRepository(auth: MockFirebaseAuth());
      await repositorio.cadastrar(email: 'nova@example.com', senha: 'senha123');
      expect(repositorio.usuarioAtual, isNotNull);
      expect(repositorio.usuarioAtual!.email, 'nova@example.com');
    });

    test('entrar autentica com um usuário mockado já existente', () async {
      final mockUser = MockUser(uid: 'uid-1', email: 'existente@example.com');
      final repositorio = AuthRepository(
        auth: MockFirebaseAuth(mockUser: mockUser),
      );

      await repositorio.entrar(email: 'existente@example.com', senha: 'senha123');
      expect(repositorio.usuarioAtual?.email, 'existente@example.com');
    });

    test('sair desconecta a usuária', () async {
      final repositorio = AuthRepository(
        auth: MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'uid-1', email: 'a@a.com'),
        ),
      );
      expect(repositorio.usuarioAtual, isNotNull);

      await repositorio.sair();
      expect(repositorio.usuarioAtual, isNull);
    });

    test('mudancasDeUsuario emite o usuário atual ao entrar e null ao sair', () async {
      final repositorio = AuthRepository(auth: MockFirebaseAuth());
      final emitidos = <bool>[];
      final assinatura = repositorio.mudancasDeUsuario.listen(
        (usuario) => emitidos.add(usuario != null),
      );

      await repositorio.cadastrar(email: 'nova@example.com', senha: 'senha123');
      await repositorio.sair();
      await Future<void>.delayed(Duration.zero);

      // O mock emite um evento inicial (ninguém logada) assim que alguém se
      // inscreve no stream, antes de qualquer entrar/sair.
      expect(emitidos, [false, true, false]);
      await assinatura.cancel();
    });
  });
}
