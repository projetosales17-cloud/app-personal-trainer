import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/anamnese.dart';
import 'sincronizador_dados.dart';

/// Persiste a anamnese localmente e sincroniza com o Firestore por conta
/// (ver [SincronizadorDados]).
class AnamneseRepository {
  static const _chave = 'anamnese';

  /// Sobe a cada `salvar`. As telas que derivam algo da anamnese (Home,
  /// Minha ficha) escutam isso pra se atualizarem quando a usuária edita
  /// a anamnese pelo Perfil na mesma sessão — sem esperar o app recarregar
  /// (o `IndexedStack` da navegação mantém as telas vivas).
  static final ValueNotifier<int> revisao = ValueNotifier<int>(0);

  Future<void> salvar(Anamnese anamnese) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chave, jsonEncode(anamnese.toJson()));
    await SincronizadorDados.instancia.aposEscrita(_chave);
    revisao.value++;
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
