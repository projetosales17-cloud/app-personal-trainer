import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Guarda os ajustes manuais que a usuária faz na ficha já gerada:
/// - **trocas** ("trocar este exercício agora" — aparelho ocupado, o
///   movimento incomoda naquele dia, etc.): mapa id original -> id do
///   substituto escolhido.
/// - **removidos** ("não fazer este exercício"): conjunto de ids que a
///   usuária tirou da ficha.
///
/// Tudo é aplicado POR CIMA da ficha gerada (ver `MinhaFichaView`), então
/// não interfere na geração nem na progressão do programa. É zerado no
/// check-in de progresso, quando uma ficha nova entra em cena.
class TrocasExercicioRepository {
  static const chave = 'trocas_exercicio';
  static const chaveRemovidos = 'exercicios_removidos';

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

  /// Ids de exercícios que a usuária tirou da ficha ("não fazer").
  Future<Set<String>> removidos() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(chaveRemovidos) ?? const []).toSet();
  }

  Future<void> remover(String exercicioId) async {
    final atual = await removidos()..add(exercicioId);
    await _salvarRemovidos(atual);
  }

  Future<void> restaurar(String exercicioId) async {
    final atual = await removidos()..remove(exercicioId);
    await _salvarRemovidos(atual);
  }

  Future<void> limparTudo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(chave);
    await prefs.remove(chaveRemovidos);
  }

  Future<void> _salvar(Map<String, String> trocas) async {
    final prefs = await SharedPreferences.getInstance();
    if (trocas.isEmpty) {
      await prefs.remove(chave);
    } else {
      await prefs.setString(chave, jsonEncode(trocas));
    }
  }

  Future<void> _salvarRemovidos(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    if (ids.isEmpty) {
      await prefs.remove(chaveRemovidos);
    } else {
      await prefs.setStringList(chaveRemovidos, ids.toList());
    }
  }
}
