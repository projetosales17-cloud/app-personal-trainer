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

  /// `true` enquanto [registrarNovaSessao] está gravando a sessão deste
  /// login. Nessa janela há corrida entre a escrita da nossa sessão e os
  /// snapshots do Firestore, então [observarEncerramento] não derruba.
  /// Fora dela, o token local é a verdade.
  bool _aguardandoRegistro = false;

  Future<void> registrarNovaSessao(String uid) async {
    _aguardandoRegistro = true;
    try {
      final token = controleSessao.gerarTokenSessao();
      // Grava o token local ANTES de escrever no Firestore, para o snapshot
      // com o nosso token já bater com o local quando chegar.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_chaveTokenLocal, token);
      await controleSessao.registrarSessao(uid, token);
    } finally {
      _aguardandoRegistro = false;
    }
  }

  /// Emite `true` quando a sessão do Firestore não é mais a local — ou
  /// seja, outro aparelho assumiu a conta. Vale também quando a troca
  /// aconteceu enquanto este aparelho estava fechado: ao reabrir, o
  /// primeiro snapshot já vem com o token do outro aparelho e a sessão
  /// local é encerrada.
  ///
  /// Durante o login/primeiro acesso ([registrarNovaSessao] em andamento),
  /// ignora as diferenças — senão o próprio login se derrubaria por causa
  /// da corrida entre gravar a sessão e receber o snapshot.
  Stream<bool> observarEncerramento(String uid) async* {
    await for (final tokenRemoto in controleSessao.observarTokenSessao(uid)) {
      if (_aguardandoRegistro) continue;

      final prefs = await SharedPreferences.getInstance();
      final tokenLocal = prefs.getString(_chaveTokenLocal);
      if (tokenLocal == null || tokenRemoto == null) continue;

      if (tokenRemoto != tokenLocal) yield true;
    }
  }
}
