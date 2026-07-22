import 'package:shared_preferences/shared_preferences.dart';

/// Persiste preferências simples do app localmente no aparelho.
///
/// A preferência de notificações aqui é só a intenção da usuária — o app
/// ainda não tem nenhum mecanismo real de notificação (push ou local) para
/// agir sobre ela (ver briefing do produto).
class PreferenciasRepository {
  static const _chaveNotificacoes = 'notificacoes_ativadas';
  static const _chaveDiasSemanaTreino = 'dias_semana_treino';

  Future<bool> notificacoesAtivadas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_chaveNotificacoes) ?? true;
  }

  Future<void> definirNotificacoesAtivadas(bool ativado) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveNotificacoes, ativado);
  }

  /// Dias da semana escolhidos manualmente para o treino (1 = segunda ... 7
  /// = domingo, ver `DateTime.weekday`), em ordem crescente. `null` quando a
  /// usuária ainda não escolheu — nesse caso a ficha usa a distribuição
  /// automática (ver `FichaTreino.datasPara`).
  Future<List<int>?> diasDaSemanaEscolhidos() async {
    final prefs = await SharedPreferences.getInstance();
    final salvos = prefs.getStringList(_chaveDiasSemanaTreino);
    if (salvos == null) return null;
    return [for (final dia in salvos) int.parse(dia)];
  }

  Future<void> definirDiasDaSemanaEscolhidos(List<int> diasDaSemana) async {
    final prefs = await SharedPreferences.getInstance();
    final ordenados = diasDaSemana.toList()..sort();
    await prefs.setStringList(_chaveDiasSemanaTreino, [
      for (final dia in ordenados) dia.toString(),
    ]);
  }
}
