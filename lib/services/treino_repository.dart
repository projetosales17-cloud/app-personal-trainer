import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/registro_carga.dart';
import 'sincronizador_dados.dart';

/// Persiste o histórico de carga localmente e sincroniza com o Firestore
/// por conta (ver [SincronizadorDados]).
class TreinoRepository {
  static const _chave = 'registros_carga';

  Future<void> registrarCarga(RegistroCarga registro) async {
    final registros = await listarCargas()..add(registro);
    await _salvar(registros);
  }

  /// Substitui o registro de carga de mesmo `id` pelos novos dados.
  Future<void> atualizarCarga(RegistroCarga registro) async {
    final registros = await listarCargas();
    final indice = registros.indexWhere((r) => r.id == registro.id);
    if (indice == -1) return;
    registros[indice] = registro;
    await _salvar(registros);
  }

  /// Remove o registro de carga de `id`.
  Future<void> removerCarga(String id) async {
    final registros = await listarCargas()..removeWhere((r) => r.id == id);
    await _salvar(registros);
  }

  Future<void> _salvar(List<RegistroCarga> registros) async {
    registros.sort((a, b) => a.data.compareTo(b.data));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chave,
      jsonEncode([for (final registro in registros) registro.toJson()]),
    );
    await SincronizadorDados.instancia.aposEscrita(_chave);
  }

  Future<List<RegistroCarga>> listarCargas() async {
    final prefs = await SharedPreferences.getInstance();
    final bruto = prefs.getString(_chave);
    if (bruto == null) return [];

    final lista = jsonDecode(bruto) as List;
    return [
      for (final item in lista) RegistroCarga.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<List<RegistroCarga>> listarCargasDoExercicio(String exercicioId) async {
    final registros = await listarCargas();
    return registros.where((registro) => registro.exercicioId == exercicioId).toList();
  }
}
