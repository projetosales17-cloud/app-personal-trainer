import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:app_personal_trainer/services/primeiro_acesso_repository.dart';

void main() {
  final endpoint = Uri.parse('https://exemplo.test/api/primeiro-acesso');

  test('POST con éxito (200) no lanza', () async {
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

  test('error del backend traduce por la clave "codigo" al español', () async {
    final client = MockClient((req) async {
      return http.Response(
        jsonEncode({'codigo': 'ja_usado', 'erro': 'texto em portugues'}),
        409,
      );
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
          contains('Olvidé mi contraseña'),
        ),
      ),
    );
  });

  test('clave desconocida cae en el "erro" del backend', () async {
    final client = MockClient((req) async {
      return http.Response(jsonEncode({'codigo': 'nova_chave', 'erro': 'mensagem X'}), 400);
    });

    await expectLater(
      PrimeiroAcessoRepository(client: client, endpoint: endpoint).definirSenha(
        email: 'a@a.com',
        codigo: 'HP1',
        senha: 'senhaBoa1',
      ),
      throwsA(
        isA<PrimeiroAcessoException>().having((e) => e.mensagem, 'mensagem', 'mensagem X'),
      ),
    );
  });

  test('fallo de red da un PrimeiroAcessoException amigable', () async {
    final client = MockClient((req) async {
      throw http.ClientException('sin red');
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
          contains('conexión'),
        ),
      ),
    );
  });
}
