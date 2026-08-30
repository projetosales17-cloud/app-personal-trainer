import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/registro_diario.dart';
import 'sincronizador_dados.dart';

/// Persiste o diário alimentar localmente e sincroniza com o Firestore por
/// conta (ver [SincronizadorDados]).
class DiarioAlimentarRepository {
  static const _chave = 'diario_alimentar';

  Future<void> registrar(String refeicao, String descricao, {DateTime? data}) async {
    final registros = await listar()
      ..add(RegistroDiario(
        data: data ?? DateTime.now(),
        refeicao: refeicao,
        descricao: descricao,
      ));
    await _salvar(registros);
  }

  /// Substitui o registro de mesmo `id` pelos novos dados. Ignora se o id
  /// não existe mais.
  Future<void> atualizar(RegistroDiario registro) async {
    final registros = await listar();
    final indice = registros.indexWhere((r) => r.id == registro.id);
    if (indice == -1) return;
    registros[indice] = registro;
    await _salvar(registros);
  }

  /// Remove o registro de `id` do diário.
  Future<void> remover(String id) async {
    final registros = await listar()..removeWhere((r) => r.id == id);
    await _salvar(registros);
  }

  Future<List<RegistroDiario>> listar() async {
    final prefs = await SharedPreferences.getInstance();
    final bruto = prefs.getString(_chave);
    if (bruto == null) return [];

    final lista = jsonDecode(bruto) as List;
    return [
      for (final item in lista) RegistroDiario.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<void> _salvar(List<RegistroDiario> registros) async {
    registros.sort((a, b) => a.data.compareTo(b.data));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chave,
      jsonEncode([for (final registro in registros) registro.toJson()]),
    );
    await SincronizadorDados.instancia.aposEscrita(_chave);
  }
}
