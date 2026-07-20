import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/registro_diario.dart';

/// Persiste o diário alimentar localmente no aparelho (sem backend por
/// enquanto), como a anamnese e o progresso.
class DiarioAlimentarRepository {
  static const _chave = 'diario_alimentar';

  Future<void> registrar(String refeicao, String descricao, {DateTime? data}) async {
    final registros = await listar()
      ..add(RegistroDiario(data: data ?? DateTime.now(), refeicao: refeicao, descricao: descricao))
      ..sort((a, b) => a.data.compareTo(b.data));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chave,
      jsonEncode([for (final registro in registros) registro.toJson()]),
    );
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
}
