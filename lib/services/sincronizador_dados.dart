import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tipo do valor guardado no SharedPreferences para cada chave sincronizada.
enum _Tipo { texto, listaTexto, booleano }

/// Sincroniza os dados locais da usuária (anamnese, programa, progresso,
/// check-ins, cargas, diário, preferências) com o Firestore, por conta
/// (`usuarios/{uid}`). Assim os dados seguem a usuária entre aparelhos e
/// não somem ao limpar o navegador — antes tudo ficava só no
/// SharedPreferences local.
///
/// Estratégia: cada chave carrega um timestamp (`<chave>__ts`). No login,
/// para cada chave, o lado mais recente vence; o que existir só localmente
/// é enviado ao servidor. Depois de cada escrita local, [aposEscrita]
/// carimba o timestamp e envia a chave (best-effort — se estiver offline,
/// fica só local e sobe no próximo login).
class SincronizadorDados {
  SincronizadorDados({FirebaseFirestore? firestore}) : _firestoreInjetado = firestore;

  /// `null` em produção — o Firestore real só é resolvido sob demanda
  /// (`_firestore`), quando de fato há um usuário logado para sincronizar.
  /// Assim os testes de repositório não precisam do Firebase inicializado.
  final FirebaseFirestore? _firestoreInjetado;

  FirebaseFirestore get _firestore => _firestoreInjetado ?? FirebaseFirestore.instance;

  /// Instância usada pelos repositórios para o envio best-effort após cada
  /// escrita. Trocável em testes.
  static SincronizadorDados instancia = SincronizadorDados();

  String? _uid;

  static const _chaves = <String, _Tipo>{
    'anamnese': _Tipo.texto,
    'programa_treino': _Tipo.texto,
    'registros_peso': _Tipo.texto,
    'registros_medidas': _Tipo.texto,
    'checkins_treino': _Tipo.texto,
    'registros_carga': _Tipo.texto,
    'diario_alimentar': _Tipo.texto,
    'dias_semana_treino': _Tipo.listaTexto,
    'notificacoes_ativadas': _Tipo.booleano,
  };

  /// Chaves que os repositórios podem passar para [aposEscrita].
  static Iterable<String> get chavesSincronizadas => _chaves.keys;

  void definirUsuario(String? uid) => _uid = uid;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection('usuarios').doc(uid);

  Object? _lerLocal(SharedPreferences prefs, String chave, _Tipo tipo) => switch (tipo) {
    _Tipo.texto => prefs.getString(chave),
    _Tipo.listaTexto => prefs.getStringList(chave),
    _Tipo.booleano => prefs.containsKey(chave) ? prefs.getBool(chave) : null,
  };

  Future<void> _escreverLocal(
    SharedPreferences prefs,
    String chave,
    _Tipo tipo,
    Object valor,
  ) async {
    switch (tipo) {
      case _Tipo.texto:
        await prefs.setString(chave, valor as String);
      case _Tipo.listaTexto:
        await prefs.setStringList(chave, (valor as List).map((e) => e.toString()).toList());
      case _Tipo.booleano:
        await prefs.setBool(chave, valor as bool);
    }
  }

  /// Chamado no login: resolve cada chave entre local e servidor (o
  /// timestamp mais novo vence) e envia o que só existe localmente.
  /// Também fixa [uid] como usuário atual para os envios seguintes.
  Future<void> sincronizarNoLogin(String uid) async {
    _uid = uid;
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> remoto;
    try {
      remoto = (await _doc(uid).get()).data() ?? const {};
    } catch (_) {
      return; // offline — segue com o que estiver local
    }

    final envio = <String, Object?>{};
    for (final entry in _chaves.entries) {
      final chave = entry.key;
      final tipo = entry.value;
      final tsChave = '${chave}__ts';
      final localTs = prefs.getInt(tsChave) ?? 0;
      final remotoTs = (remoto[tsChave] as num?)?.toInt() ?? 0;
      final temRemoto = remoto[chave] != null;
      final localValor = _lerLocal(prefs, chave, tipo);

      if (temRemoto && remotoTs >= localTs) {
        await _escreverLocal(prefs, chave, tipo, remoto[chave] as Object);
        await prefs.setInt(
          tsChave,
          remotoTs == 0 ? DateTime.now().millisecondsSinceEpoch : remotoTs,
        );
      } else if (localValor != null && (localTs > remotoTs || !temRemoto)) {
        final ts = localTs == 0 ? DateTime.now().millisecondsSinceEpoch : localTs;
        envio[chave] = localValor;
        envio[tsChave] = ts;
        await prefs.setInt(tsChave, ts);
      }
    }

    if (envio.isNotEmpty) {
      try {
        await _doc(uid).set(envio, SetOptions(merge: true));
      } catch (_) {
        // offline — sobe no próximo login
      }
    }
  }

  /// Best-effort após uma escrita local numa chave sincronizada. Sem
  /// usuário logado (ou offline) não faz nada além de carimbar o
  /// timestamp local.
  Future<void> aposEscrita(String chave) async {
    if (!_chaves.containsKey(chave)) return;
    final prefs = await SharedPreferences.getInstance();
    final ts = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('${chave}__ts', ts);

    final uid = _uid;
    if (uid == null) return;
    final valor = _lerLocal(prefs, chave, _chaves[chave]!);
    if (valor == null) return;
    try {
      await _doc(uid).set({chave: valor, '${chave}__ts': ts}, SetOptions(merge: true));
    } catch (_) {
      // offline — sobe no próximo login
    }
  }
}
