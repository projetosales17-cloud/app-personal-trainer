import 'dart:convert';

import 'package:http/http.dart' as http;

/// Erro do fluxo de primeiro acesso, com mensagem já pronta pra UI.
class PrimeiroAcessoException implements Exception {
  const PrimeiroAcessoException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Mensagens por chave de erro do backend. O backend já responde em
/// português, mas mapear pela chave deixa a mensagem consistente e
/// independente de mudança de texto no servidor.
const _mensagensPorCodigo = {
  'dados_invalidos':
      'Não encontramos uma compra com esses dados. Confira o e-mail e o código da compra (do seu recibo da Hotmart, começa com HP).',
  'nao_encontrado':
      'Não encontramos uma compra com esses dados. Confira o e-mail e o código da compra (do seu recibo da Hotmart, começa com HP).',
  'senha_curta': 'A senha precisa ter pelo menos 6 caracteres.',
  'conta_antiga':
      'Essa conta já foi ativada antes. Use a opção "Esqueci minha senha" para entrar.',
  'ja_usado':
      'Esse código de primeiro acesso já foi usado. Use "Esqueci minha senha" para trocar a senha.',
  'muitas_tentativas':
      'Muitas tentativas com dados incorretos. Aguarde um pouco e use "Esqueci minha senha", ou fale com o suporte.',
  'interno': 'Erro no servidor. Tente novamente em instantes.',
};

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

    String? codigoErro;
    String? erroBackend;
    try {
      final corpo = jsonDecode(resposta.body);
      if (corpo is Map) {
        if (corpo['codigo'] is String) codigoErro = corpo['codigo'] as String;
        if (corpo['erro'] is String) erroBackend = corpo['erro'] as String;
      }
    } catch (_) {
      // corpo não-JSON — cai na mensagem genérica abaixo
    }
    throw PrimeiroAcessoException(
      _mensagensPorCodigo[codigoErro] ??
          erroBackend ??
          'Não foi possível concluir o primeiro acesso. Tente de novo.',
    );
  }
}
