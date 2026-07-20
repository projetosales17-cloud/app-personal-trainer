import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/registro_medidas.dart';
import '../models/registro_peso.dart';

/// Persiste os registros de peso e medidas localmente no aparelho (sem
/// backend por enquanto), como a anamnese.
class ProgressoRepository {
  static const _chave = 'registros_peso';
  static const _chaveMedidas = 'registros_medidas';

  Future<void> registrarPeso(double pesoKg, {DateTime? data}) async {
    final registros = await listarPesos()
      ..add(RegistroPeso(data: data ?? DateTime.now(), pesoKg: pesoKg))
      ..sort((a, b) => a.data.compareTo(b.data));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chave,
      jsonEncode([for (final registro in registros) registro.toJson()]),
    );
  }

  Future<List<RegistroPeso>> listarPesos() async {
    final prefs = await SharedPreferences.getInstance();
    final bruto = prefs.getString(_chave);
    if (bruto == null) return [];

    final lista = jsonDecode(bruto) as List;
    return [
      for (final item in lista) RegistroPeso.fromJson(item as Map<String, dynamic>),
    ];
  }

  /// Retorna o registro mais recente, ou nulo se nenhum foi feito ainda.
  Future<RegistroPeso?> ultimoPeso() async {
    final registros = await listarPesos();
    return registros.isEmpty ? null : registros.last;
  }

  Future<void> registrarMedidas(RegistroMedidas registro) async {
    final registros = await listarMedidas()
      ..add(registro)
      ..sort((a, b) => a.data.compareTo(b.data));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chaveMedidas,
      jsonEncode([for (final registro in registros) registro.toJson()]),
    );
  }

  Future<List<RegistroMedidas>> listarMedidas() async {
    final prefs = await SharedPreferences.getInstance();
    final bruto = prefs.getString(_chaveMedidas);
    if (bruto == null) return [];

    final lista = jsonDecode(bruto) as List;
    return [
      for (final item in lista) RegistroMedidas.fromJson(item as Map<String, dynamic>),
    ];
  }
}
