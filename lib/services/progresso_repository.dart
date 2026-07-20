import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/registro_foto.dart';
import '../models/registro_medidas.dart';
import '../models/registro_peso.dart';
import '../models/registro_video.dart';

/// Persiste os registros de peso, medidas, fotos e vídeos localmente no
/// aparelho (sem backend por enquanto, sem custo de nuvem), como a
/// anamnese.
class ProgressoRepository {
  ProgressoRepository({Future<Directory> Function()? resolverDiretorioBase})
    : _resolverDiretorioBase = resolverDiretorioBase ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _resolverDiretorioBase;

  static const _chave = 'registros_peso';
  static const _chaveMedidas = 'registros_medidas';
  static const _chaveFotos = 'registros_fotos';
  static const _chaveVideos = 'registros_videos';

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

  /// Copia o arquivo de origem para uma pasta própria do app (fora da
  /// cache temporária de onde o seletor de imagem costuma entregar o
  /// arquivo) e registra a foto de progresso.
  Future<RegistroFoto> registrarFoto(File arquivoOrigem) async {
    final pasta = await _pastaFotos();
    final registrosExistentes = await listarFotos();

    final pontoExtensao = arquivoOrigem.path.lastIndexOf('.');
    final extensao = pontoExtensao == -1 ? '' : arquivoOrigem.path.substring(pontoExtensao);
    final nomeArquivo =
        '${DateTime.now().microsecondsSinceEpoch}_${registrosExistentes.length}$extensao';
    final destino = await arquivoOrigem.copy('${pasta.path}/$nomeArquivo');

    final registro = RegistroFoto(data: DateTime.now(), caminhoArquivo: destino.path);
    final registros = registrosExistentes..add(registro);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chaveFotos,
      jsonEncode([for (final item in registros) item.toJson()]),
    );
    return registro;
  }

  Future<List<RegistroFoto>> listarFotos() async {
    final prefs = await SharedPreferences.getInstance();
    final bruto = prefs.getString(_chaveFotos);
    if (bruto == null) return [];

    final lista = jsonDecode(bruto) as List;
    return [
      for (final item in lista) RegistroFoto.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<Directory> _pastaFotos() => _pasta('fotos_progresso');

  /// Copia o arquivo de origem para uma pasta própria do app e registra o
  /// vídeo de progresso. Sem geração de miniatura ainda — a grade mostra
  /// só um ícone genérico + data (ver briefing do produto).
  Future<RegistroVideo> registrarVideo(File arquivoOrigem) async {
    final pasta = await _pastaVideos();
    final registrosExistentes = await listarVideos();

    final pontoExtensao = arquivoOrigem.path.lastIndexOf('.');
    final extensao = pontoExtensao == -1 ? '' : arquivoOrigem.path.substring(pontoExtensao);
    final nomeArquivo =
        '${DateTime.now().microsecondsSinceEpoch}_${registrosExistentes.length}$extensao';
    final destino = await arquivoOrigem.copy('${pasta.path}/$nomeArquivo');

    final registro = RegistroVideo(data: DateTime.now(), caminhoArquivo: destino.path);
    final registros = registrosExistentes..add(registro);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chaveVideos,
      jsonEncode([for (final item in registros) item.toJson()]),
    );
    return registro;
  }

  Future<List<RegistroVideo>> listarVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final bruto = prefs.getString(_chaveVideos);
    if (bruto == null) return [];

    final lista = jsonDecode(bruto) as List;
    return [
      for (final item in lista) RegistroVideo.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<Directory> _pastaVideos() => _pasta('videos_progresso');

  Future<Directory> _pasta(String nome) async {
    final base = await _resolverDiretorioBase();
    final pasta = Directory('${base.path}/$nome');
    if (!pasta.existsSync()) {
      pasta.createSync(recursive: true);
    }
    return pasta;
  }
}
