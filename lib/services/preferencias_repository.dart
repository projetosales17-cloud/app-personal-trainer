import 'package:shared_preferences/shared_preferences.dart';

/// Persiste preferências simples do app localmente no aparelho.
///
/// A preferência de notificações aqui é só a intenção da usuária — o app
/// ainda não tem nenhum mecanismo real de notificação (push ou local) para
/// agir sobre ela (ver briefing do produto).
class PreferenciasRepository {
  static const _chaveNotificacoes = 'notificacoes_ativadas';

  Future<bool> notificacoesAtivadas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_chaveNotificacoes) ?? true;
  }

  Future<void> definirNotificacoesAtivadas(bool ativado) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveNotificacoes, ativado);
  }
}
