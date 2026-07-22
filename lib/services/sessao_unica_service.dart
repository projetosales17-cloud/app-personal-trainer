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
    await controleSessao.registrarSessao(uid, token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveTokenLocal, token);
  }

  /// Emite `true` quando a sessão local foi substituída por outro
  /// aparelho (o token registrado no Firestore não é mais o local).
  Stream<bool> observarEncerramento(String uid) async* {
    final prefs = await SharedPreferences.getInstance();
    final tokenLocal = prefs.getString(_chaveTokenLocal);
    if (tokenLocal == null) return;

    await for (final tokenRemoto in controleSessao.observarTokenSessao(uid)) {
      if (tokenRemoto != null && tokenRemoto != tokenLocal) {
        yield true;
      }
    }
  }
}
