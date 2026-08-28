import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Guarda as trocas manuais de exercício que a usuária faz na ficha
/// ("trocar este exercício agora" — quando o aparelho está ocupado, o
/// movimento incomoda naquele dia, etc.). Mapa: id do exercício original
/// -> id do substituto escolhido.
///
/// As trocas são aplicadas POR CIMA da ficha já gerada (ver
/// `MinhaFichaView`), então não interferem na lógica de geração nem na
/// progressão do programa. São zeradas no check-in de progresso, quando
/// uma ficha nova entra em cena.
class TrocasExercicioRepository {
  static const chave = 'trocas_exercicio';

  Future<Map<String, String>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(chave);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((original, substituto) => MapEntry(original, substituto as String));
  }

  Future<void> trocar(String exercicioOriginalId, String exercicioSubstitutoId) async {
    final atual = await carregar();
    atual[exercicioOriginalId] = exercicioSubstitutoId;
    await _salvar(atual);
  }

  Future<void> desfazer(String exercicioOriginalId) async {
    final atual = await carregar();
    atual.remove(exercicioOriginalId);
    await _salvar(atual);
  }

  Future<void> limparTudo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(chave);
  }

  Future<void> _salvar(Map<String, String> trocas) async {
    final prefs = await SharedPreferences.getInstance();
    if (trocas.isEmpty) {
      await prefs.remove(chave);
    } else {
      await prefs.setString(chave, jsonEncode(trocas));
    }
  }
}
