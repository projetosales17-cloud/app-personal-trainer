import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/checkin_treino.dart';
import 'sincronizador_dados.dart';

/// Persiste os check-ins de treino localmente e sincroniza com o Firestore
/// por conta (ver [SincronizadorDados]).
class CheckinTreinoRepository {
  static const _chave = 'checkins_treino';

  Future<void> marcarConcluido(DateTime data, int diaFicha) async {
    final registros = await listar();
    final dataNormalizada = _normalizar(data);
    final jaExiste = registros.any(
      (r) => r.data == dataNormalizada && r.diaFicha == diaFicha,
    );
    if (jaExiste) return;

    registros.add(CheckinTreino(data: dataNormalizada, diaFicha: diaFicha));
    await _salvar(registros);
  }

  Future<void> desmarcarConcluido(DateTime data, int diaFicha) async {
    final registros = await listar();
    final dataNormalizada = _normalizar(data);
    registros.removeWhere(
      (r) => r.data == dataNormalizada && r.diaFicha == diaFicha,
    );
    await _salvar(registros);
  }

  Future<bool> foiConcluido(DateTime data, int diaFicha) async {
    final registros = await listar();
    final dataNormalizada = _normalizar(data);
    return registros.any(
      (r) => r.data == dataNormalizada && r.diaFicha == diaFicha,
    );
  }

  Future<List<CheckinTreino>> listar() async {
    final prefs = await SharedPreferences.getInstance();
    final bruto = prefs.getString(_chave);
    if (bruto == null) return [];

    final lista = jsonDecode(bruto) as List;
    return [
      for (final item in lista) CheckinTreino.fromJson(item as Map<String, dynamic>),
    ];
  }

  DateTime _normalizar(DateTime data) => DateTime(data.year, data.month, data.day);

  Future<void> _salvar(List<CheckinTreino> registros) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chave,
      jsonEncode([for (final registro in registros) registro.toJson()]),
    );
    await SincronizadorDados.instancia.aposEscrita(_chave);
  }
}
