import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/registro_carga.dart';

/// Persiste o histórico de carga localmente no aparelho (sem backend por
/// enquanto), como a anamnese e o progresso.
class TreinoRepository {
  static const _chave = 'registros_carga';

  Future<void> registrarCarga(RegistroCarga registro) async {
    final registros = await listarCargas()
      ..add(registro)
      ..sort((a, b) => a.data.compareTo(b.data));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chave,
      jsonEncode([for (final registro in registros) registro.toJson()]),
    );
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
