import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:app_personal_trainer/services/primeiro_acesso_repository.dart';

void main() {
  final endpoint = Uri.parse('https://exemplo.test/api/primeiro-acesso');

  test('POST com sucesso (200) não lança', () async {
    late String corpoEnviado;
    final client = MockClient((req) async {
      corpoEnviado = req.body;
      expect(req.url, endpoint);
      expect(req.headers['Content-Type'], contains('application/json'));
      return http.Response('{"ok":true}', 200);
    });

    await PrimeiroAcessoRepository(client: client, endpoint: endpoint).definirSenha(
      email: ' Cliente@Hotmail.com ',
      codigo: ' hp123 ',
      senha: 'senhaBoa1',
    );

    final json = jsonDecode(corpoEnviado) as Map<String, dynamic>;
    expect(json['email'], 'Cliente@Hotmail.com');
    expect(json['codigo'], 'hp123');
    expect(json['senha'], 'senhaBoa1');
  });

  test('erro do backend (4xx) vira PrimeiroAcessoException com a mensagem do "erro"', () async {
    final client = MockClient((req) async {
      return http.Response('{"erro":"Código não confere."}', 400);
    });

    await expectLater(
      PrimeiroAcessoRepository(client: client, endpoint: endpoint).definirSenha(
        email: 'a@a.com',
        codigo: 'HP1',
        senha: 'senhaBoa1',
      ),
      throwsA(
        isA<PrimeiroAcessoException>().having(
          (e) => e.mensagem,
          'mensagem',
          'Código não confere.',
        ),
      ),
    );
  });

  test('falha de rede vira PrimeiroAcessoException amigável', () async {
    final client = MockClient((req) async {
      throw http.ClientException('sem rede');
    });

    await expectLater(
      PrimeiroAcessoRepository(client: client, endpoint: endpoint).definirSenha(
        email: 'a@a.com',
        codigo: 'HP1',
        senha: 'senhaBoa1',
      ),
      throwsA(
        isA<PrimeiroAcessoException>().having(
          (e) => e.mensagem,
          'mensagem',
          contains('conexão'),
        ),
      ),
    );
  });

  test('resposta não-JSON com status de erro ainda vira exceção', () async {
    final client = MockClient((req) async => http.Response('Bad Gateway', 502));

    await expectLater(
      PrimeiroAcessoRepository(client: client, endpoint: endpoint).definirSenha(
        email: 'a@a.com',
        codigo: 'HP1',
        senha: 'senhaBoa1',
      ),
      throwsA(isA<PrimeiroAcessoException>()),
    );
  });
}
