import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/anamnese.dart';

/// Persiste a anamnese localmente no aparelho (sem backend por enquanto).
class AnamneseRepository {
  static const _chave = 'anamnese';

  Future<void> salvar(Anamnese anamnese) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chave, jsonEncode(anamnese.toJson()));
  }

  Future<Anamnese?> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final bruto = prefs.getString(_chave);
    if (bruto == null) return null;
    return Anamnese.fromJson(jsonDecode(bruto) as Map<String, dynamic>);
  }

  Future<bool> onboardingConcluido() async {
    final anamnese = await carregar();
    return anamnese != null;
  }
}
