import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/anamnese.dart';
import 'sincronizador_dados.dart';

/// Persiste a anamnese localmente e sincroniza com o Firestore por conta
/// (ver [SincronizadorDados]).
class AnamneseRepository {
  static const _chave = 'anamnese';

  Future<void> salvar(Anamnese anamnese) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chave, jsonEncode(anamnese.toJson()));
    await SincronizadorDados.instancia.aposEscrita(_chave);
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
