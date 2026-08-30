import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/registro_foto.dart';
import '../models/registro_medidas.dart';
import '../models/registro_peso.dart';
import '../models/registro_video.dart';
import 'gerador_miniatura_video.dart';
import 'sincronizador_dados.dart';

/// Persiste os registros de peso, medidas, fotos e vídeos da usuária.
///
/// Peso e medidas ficam no SharedPreferences local e sobem no blob de
/// `usuarios/{uid}` via [SincronizadorDados]. As **fotos de progresso** vão
/// para a subcoleção `usuarios/{uid}/fotos_progresso/{id}` como data URI
/// base64 (uma por documento, longe do limite de 1 MB do blob) — assim
/// funcionam na web e no celular e seguem a usuária entre aparelhos, sem
/// depender do Firebase Storage (plano pago). Os **vídeos** seguem só
/// locais no aparelho (arquivos grandes demais para o Firestore).
class ProgressoRepository {
  ProgressoRepository({
    Future<Directory> Function()? resolverDiretorioBase,
    GerarMiniaturaVideo? gerarMiniaturaVideo,
    FirebaseFirestore? firestore,
    String? Function()? uidAtual,
  }) : _resolverDiretorioBase = resolverDiretorioBase ?? getApplicationDocumentsDirectory,
       _gerarMiniaturaVideo = gerarMiniaturaVideo ?? gerarMiniaturaVideoPadrao,
       _firestoreInjetado = firestore,
       _uidAtual = uidAtual ?? _uidLogado;

  /// Resolve o uid da usuária logada. Protegido para não estourar quando
  /// o Firebase não foi inicializado (testes de peso/medidas, etc.).
  static String? _uidLogado() {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  final Future<Directory> Function() _resolverDiretorioBase;
  final GerarMiniaturaVideo _gerarMiniaturaVideo;

  /// `null` em produção — o Firestore real só é tocado quando há uma
  /// usuária logada e uma operação de foto, então os testes de peso/medidas
  /// não precisam do Firebase.
  final FirebaseFirestore? _firestoreInjetado;
  final String? Function() _uidAtual;

  FirebaseFirestore get _firestore => _firestoreInjetado ?? FirebaseFirestore.instance;

  static const _chave = 'registros_peso';
  static const _chaveMedidas = 'registros_medidas';
  static const _chaveFotos = 'registros_fotos';
  static const _chaveVideos = 'registros_videos';

  Future<void> registrarPeso(double pesoKg, {DateTime? data}) async {
    final registros = await listarPesos()
      ..add(RegistroPeso(data: data ?? DateTime.now(), pesoKg: pesoKg));
    await _salvarPesos(registros);
  }

  /// Substitui o registro de peso de mesmo `id` pelos novos dados.
  Future<void> atualizarPeso(RegistroPeso registro) async {
    final registros = await listarPesos();
    final indice = registros.indexWhere((r) => r.id == registro.id);
    if (indice == -1) return;
    registros[indice] = registro;
    await _salvarPesos(registros);
  }

  /// Remove o registro de peso de `id`.
  Future<void> removerPeso(String id) async {
    final registros = await listarPesos()..removeWhere((r) => r.id == id);
    await _salvarPesos(registros);
  }

  Future<void> _salvarPesos(List<RegistroPeso> registros) async {
    registros.sort((a, b) => a.data.compareTo(b.data));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chave,
      jsonEncode([for (final registro in registros) registro.toJson()]),
    );
    await SincronizadorDados.instancia.aposEscrita(_chave);
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
    final registros = await listarMedidas()..add(registro);
    await _salvarMedidas(registros);
  }

  /// Substitui o registro de medidas de mesmo `id` pelos novos dados.
  Future<void> atualizarMedidas(RegistroMedidas registro) async {
    final registros = await listarMedidas();
    final indice = registros.indexWhere((r) => r.id == registro.id);
    if (indice == -1) return;
    registros[indice] = registro;
    await _salvarMedidas(registros);
  }

  /// Remove o registro de medidas de `id`.
  Future<void> removerMedidas(String id) async {
    final registros = await listarMedidas()..removeWhere((r) => r.id == id);
    await _salvarMedidas(registros);
  }

  Future<void> _salvarMedidas(List<RegistroMedidas> registros) async {
    registros.sort((a, b) => a.data.compareTo(b.data));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chaveMedidas,
      jsonEncode([for (final registro in registros) registro.toJson()]),
    );
    await SincronizadorDados.instancia.aposEscrita(_chaveMedidas);
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

  CollectionReference<Map<String, dynamic>>? _colecaoFotos() {
    final uid = _uidAtual();
    if (uid == null) return null;
    return _firestore.collection('usuarios').doc(uid).collection('fotos_progresso');
  }

  Future<void> _salvarCacheFotos(List<RegistroFoto> fotos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chaveFotos,
      jsonEncode([for (final f in fotos) f.toJson()]),
    );
  }

  Future<List<RegistroFoto>> _cacheFotos() async {
    final prefs = await SharedPreferences.getInstance();
    final bruto = prefs.getString(_chaveFotos);
    if (bruto == null) return [];
    final lista = jsonDecode(bruto) as List;
    return [
      for (final item in lista)
        if ((item as Map)['dataUri'] != null)
          RegistroFoto.fromJson(item.cast<String, dynamic>()),
    ]..sort((a, b) => a.data.compareTo(b.data));
  }

  /// Registra uma foto de progresso a partir dos bytes da imagem (já
  /// redimensionada/comprimida pelo seletor). Guarda como data URI base64
  /// no Firestore (`usuarios/{uid}/fotos_progresso`) quando há usuária
  /// logada, e sempre no cache local. Offline, fica só no cache com id
  /// `local_...` até a próxima listagem online.
  Future<RegistroFoto> registrarFoto(
    Uint8List bytes, {
    String mime = 'image/jpeg',
    PoseFoto pose = PoseFoto.livre,
  }) async {
    final agora = DateTime.now();
    final dataUri = 'data:$mime;base64,${base64Encode(bytes)}';

    var id = 'local_${agora.microsecondsSinceEpoch}';
    final colecao = _colecaoFotos();
    if (colecao != null) {
      try {
        final ref = await colecao.add({
          'data': Timestamp.fromDate(agora),
          'dataUri': dataUri,
          'pose': pose.name,
        });
        id = ref.id;
      } catch (_) {
        // offline — sobe na próxima listagem online
      }
    }

    final registro = RegistroFoto(id: id, data: agora, dataUri: dataUri, pose: pose);
    await _salvarCacheFotos([...await _cacheFotos(), registro]);
    return registro;
  }

  /// Lista as fotos de progresso ordenadas da mais antiga para a mais
  /// recente. Com usuária logada, lê do Firestore e atualiza o cache
  /// local; offline (ou deslogada), devolve o cache.
  Future<List<RegistroFoto>> listarFotos() async {
    final colecao = _colecaoFotos();
    if (colecao != null) {
      try {
        final snap = await colecao.orderBy('data').get();
        final fotos = [for (final doc in snap.docs) _fotoDeDoc(doc)];
        await _salvarCacheFotos(fotos);
        return fotos;
      } catch (_) {
        // offline — cai no cache
      }
    }
    return _cacheFotos();
  }

  RegistroFoto _fotoDeDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
      RegistroFoto.fromJson({
        'id': doc.id,
        'data': (doc.data()['data'] as Timestamp).toDate().toIso8601String(),
        'dataUri': doc.data()['dataUri'],
        'pose': doc.data()['pose'],
      });

  /// Uma página da grade, da foto mais recente para a mais antiga.
  /// [antesDe] é a data da última foto já carregada (cursor). Paginação de
  /// verdade só com o Firestore; deslogada/offline (ou regras ainda não
  /// deployadas) devolve o cache local inteiro na primeira página.
  Future<List<RegistroFoto>> paginaFotos({required int limite, DateTime? antesDe}) async {
    final colecao = _colecaoFotos();
    if (colecao != null) {
      try {
        var consulta = colecao.orderBy('data', descending: true);
        if (antesDe != null) {
          consulta = consulta.where('data', isLessThan: Timestamp.fromDate(antesDe));
        }
        final snap = await consulta.limit(limite).get();
        return [for (final doc in snap.docs) _fotoDeDoc(doc)];
      } catch (_) {
        // offline / regras não deployadas — cai no cache
      }
    }
    if (antesDe != null) return const <RegistroFoto>[];
    return (await _cacheFotos()).reversed.toList();
  }

  /// Troca o ângulo (pose) de uma foto de progresso já registrada —
  /// documento do Firestore + cache local.
  Future<void> atualizarPoseFoto(String id, PoseFoto pose) async {
    final colecao = _colecaoFotos();
    if (colecao != null && !id.startsWith('local_')) {
      try {
        await colecao.doc(id).update({'pose': pose.name});
      } catch (_) {
        // offline — a pose antiga volta na próxima listagem
      }
    }
    final atualizadas = [
      for (final f in await _cacheFotos())
        if (f.id == id)
          RegistroFoto(id: f.id, data: f.data, dataUri: f.dataUri, pose: pose)
        else
          f,
    ];
    await _salvarCacheFotos(atualizadas);
  }

  /// Remove uma foto de progresso (documento do Firestore + cache local).
  Future<void> removerFoto(String id) async {
    final colecao = _colecaoFotos();
    if (colecao != null && !id.startsWith('local_')) {
      try {
        await colecao.doc(id).delete();
      } catch (_) {
        // offline — a foto volta a aparecer até conseguir apagar de novo
      }
    }
    final restantes = (await _cacheFotos()).where((f) => f.id != id).toList();
    await _salvarCacheFotos(restantes);
  }

  /// Copia o arquivo de origem para uma pasta própria do app, gera uma
  /// miniatura (quando suportado pela plataforma, ver
  /// gerador_miniatura_video.dart) e registra o vídeo de progresso.
  Future<RegistroVideo> registrarVideo(File arquivoOrigem) async {
    final pasta = await _pastaVideos();
    final registrosExistentes = await listarVideos();

    final pontoExtensao = arquivoOrigem.path.lastIndexOf('.');
    final extensao = pontoExtensao == -1 ? '' : arquivoOrigem.path.substring(pontoExtensao);
    final nomeArquivo =
        '${DateTime.now().microsecondsSinceEpoch}_${registrosExistentes.length}$extensao';
    final destino = await arquivoOrigem.copy('${pasta.path}/$nomeArquivo');

    final pastaMiniaturas = await _pastaMiniaturasVideos();
    final caminhoMiniatura = await _gerarMiniaturaVideo(destino.path, pastaMiniaturas.path);

    final registro = RegistroVideo(
      data: DateTime.now(),
      caminhoArquivo: destino.path,
      caminhoMiniatura: caminhoMiniatura,
    );
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

  /// Remove o vídeo de `id`: apaga o arquivo e a miniatura do disco
  /// (best-effort) e tira o registro da lista local.
  Future<void> removerVideo(String id) async {
    final registros = await listarVideos();
    for (final registro in registros.where((v) => v.id == id)) {
      for (final caminho in [registro.caminhoArquivo, registro.caminhoMiniatura]) {
        if (caminho == null) continue;
        try {
          final arquivo = File(caminho);
          if (arquivo.existsSync()) arquivo.deleteSync();
        } catch (_) {
          // arquivo já sumiu ou sem permissão — o registro sai da lista mesmo assim
        }
      }
    }
    registros.removeWhere((v) => v.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chaveVideos,
      jsonEncode([for (final item in registros) item.toJson()]),
    );
  }

  Future<Directory> _pastaVideos() => _pasta('videos_progresso');

  Future<Directory> _pastaMiniaturasVideos() => _pasta('miniaturas_videos_progresso');

  Future<Directory> _pasta(String nome) async {
    final base = await _resolverDiretorioBase();
    final pasta = Directory('${base.path}/$nome');
    if (!pasta.existsSync()) {
      pasta.createSync(recursive: true);
    }
    return pasta;
  }
}
