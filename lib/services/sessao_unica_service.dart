import 'package:shared_preferences/shared_preferences.dart';

import 'controle_sessao.dart';

/// Garante "1 licença = 1 usuária" (ver briefing do produto): ao entrar,
/// registra uma sessão nova; se outro aparelho assumir a conta depois,
/// [observarEncerramento] emite um evento para a UI encerrar a sessão local.
class SessaoUnicaService {
  SessaoUnicaService({ControleSessao? controleSessao})
    : controleSessao = controleSessao ?? ControleSessaoFirestore();

  final ControleSessao controleSessao;

  static const _chaveTokenLocal = 'token_sessao_local';

  Future<void> registrarNovaSessao(String uid) async {
    final token = controleSessao.gerarTokenSessao();
    // Grava o token local ANTES de escrever no Firestore. Assim, quando o
    // snapshot do Firestore com esse mesmo token chegar em
    // [observarEncerramento] (que roda em paralelo, disparado pelo
    // authStateChanges do login), o valor local já vai bater e o aparelho
    // não se desconecta sozinho achando que foi "assumido por outro".
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveTokenLocal, token);
    await controleSessao.registrarSessao(uid, token);
  }

  /// Emite `true` quando a sessão local foi substituída por outro
  /// aparelho (o token registrado no Firestore não é mais o local).
  ///
  /// Só passa a vigiar depois de ver o próprio token no Firestore pelo
  /// menos uma vez. Um snapshot anterior ao registro desta sessão — com o
  /// token de uma tentativa passada nesta instalação, ou de outro aparelho
  /// que entrou antes — não conta como "assumida por outro aparelho";
  /// senão o próprio login se derrubaria por causa da corrida entre o
  /// registro da sessão e o início da vigilância.
  Stream<bool> observarEncerramento(String uid) async* {
    var viuTokenProprio = false;

    await for (final tokenRemoto in controleSessao.observarTokenSessao(uid)) {
      final prefs = await SharedPreferences.getInstance();
      final tokenLocal = prefs.getString(_chaveTokenLocal);
      if (tokenLocal == null || tokenRemoto == null) continue;

      if (tokenRemoto == tokenLocal) {
        viuTokenProprio = true;
      } else if (viuTokenProprio) {
        yield true;
      }
    }
  }
}
