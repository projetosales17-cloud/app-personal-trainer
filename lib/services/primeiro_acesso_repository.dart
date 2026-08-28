import 'dart:convert';

import 'package:http/http.dart' as http;

/// Error del flujo de primer acceso, con mensaje listo para la UI.
class PrimeiroAcessoException implements Exception {
  const PrimeiroAcessoException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Mensajes en español por clave de error del backend (que responde en
/// portugués). Si llega una clave desconocida, se usa el `erro` del
/// backend y, en último caso, un genérico.
const _mensagensPorCodigo = {
  'dados_invalidos':
      'No encontramos una compra con esos datos. Revisa el correo y el código de compra (está en tu recibo de Hotmart, empieza con HP).',
  'nao_encontrado':
      'No encontramos una compra con esos datos. Revisa el correo y el código de compra (está en tu recibo de Hotmart, empieza con HP).',
  'senha_curta': 'La contraseña debe tener al menos 6 caracteres.',
  'conta_antiga':
      'Esta cuenta ya fue activada antes. Usa la opción "Olvidé mi contraseña" para entrar.',
  'ja_usado':
      'Ese código de primer acceso ya fue usado. Usa "Olvidé mi contraseña" para cambiar la contraseña.',
  'muitas_tentativas':
      'Demasiados intentos con datos incorrectos. Espera un momento y usa "Olvidé mi contraseña", o contacta con soporte.',
  'interno': 'Error del servidor. Inténtalo de nuevo en unos instantes.',
};

/// Habla con el endpoint `/api/primeiro-acesso` de Vercel (el mismo
/// proyecto del webhook de Hotmart). La compradora prueba la compra con el
/// par (correo, código de la transacción) y el backend define la
/// contraseña de la cuenta que el webhook creó sin contraseña. Después de
/// eso la app inicia sesión normal.
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

  /// Define la contraseña de la cuenta. Éxito = retorna sin error;
  /// cualquier problema se convierte en [PrimeiroAcessoException] con el
  /// mensaje en español.
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
        'No pudimos comunicarnos con el servidor. Revisa tu conexión e inténtalo de nuevo.',
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
      // cuerpo no-JSON
    }

    throw PrimeiroAcessoException(
      _mensagensPorCodigo[codigoErro] ??
          erroBackend ??
          'No pudimos completar el primer acceso. Inténtalo de nuevo.',
    );
  }
}
