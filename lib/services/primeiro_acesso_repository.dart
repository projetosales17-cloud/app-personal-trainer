import 'dart:convert';

import 'package:http/http.dart' as http;

/// Erro do fluxo de primeiro acesso, com mensagem já pronta pra UI.
class PrimeiroAcessoException implements Exception {
  const PrimeiroAcessoException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Fala com o endpoint `/api/primeiro-acesso` da Vercel (mesmo projeto do
/// webhook da Hotmart). A compradora prova a compra com o par
/// (e-mail, código da transação) e o backend define a senha da conta que
/// o webhook criou sem senha. Depois disso o app faz login normal.
class PrimeiroAcessoRepository {
  PrimeiroAcessoRepository({http.Client? client, Uri? endpoint})
    : _client = client ?? http.Client(),
      _endpoint =
          endpoint ??
          Uri.parse(
            'https://hotmart-webhook-zeta.vercel.app/api/primeiro-acesso',
          );

  final http.Client _client;
  final Uri _endpoint;

  /// Define a senha da conta. Sucesso = retorna sem erro; qualquer
  /// problema vira [PrimeiroAcessoException] com a mensagem do backend.
  Future<void> definirSenha({
    required String email,
    required String codigo,
    required String senha,
  }) async {
    http.Response resposta;
    try {
      resposta = await _client.post(
        _endpoint,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'codigo': codigo.trim(),
          'senha': senha,
        }),
      );
    } catch (_) {
      throw const PrimeiroAcessoException(
        'Não foi possível falar com o servidor. Verifique sua conexão e tente de novo.',
      );
    }

    if (resposta.statusCode == 200) return;

    String? mensagem;
    try {
      final corpo = jsonDecode(resposta.body);
      if (corpo is Map && corpo['erro'] is String) {
        mensagem = corpo['erro'] as String;
      }
    } catch (_) {
      // corpo não-JSON — cai na mensagem genérica abaixo
    }
    throw PrimeiroAcessoException(
      mensagem ?? 'Não foi possível concluir o primeiro acesso. Tente de novo.',
    );
  }
}
