import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Foto de perfil da usuária — uma imagem só, mostrada na Home e no Perfil
/// para o app ter cara de pessoal. Guardada como data URI base64 no
/// documento `usuarios/{uid}/perfil/foto` do Firestore (segue entre
/// aparelhos, sem depender do Firebase Storage / plano pago) e num cache
/// local (SharedPreferences) para aparecer na hora, mesmo offline. Mesma
/// abordagem das fotos de progresso — ver [ProgressoRepository].
class FotoPerfilRepository {
  FotoPerfilRepository({FirebaseFirestore? firestore, String? Function()? uidAtual})
    : _firestoreInjetado = firestore,
      _uidAtual = uidAtual ?? _uidLogado;

  /// uid da usuária logada. Protegido para não estourar quando o Firebase
  /// não foi inicializado (testes que não tocam no Firestore).
  static String? _uidLogado() {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  final FirebaseFirestore? _firestoreInjetado;
  final String? Function() _uidAtual;

  /// Última foto de perfil conhecida nesta sessão (data URI, ou `null` sem
  /// foto). É a fonte que a Home e o Perfil escutam pra mostrar o avatar
  /// sempre igual, sem recarregar — o `IndexedStack` da navegação mantém as
  /// telas vivas, então a Home não recarrega sozinha ao voltar do Perfil.
  /// Preenchido pelo primeiro [carregar] e atualizado por [salvar]/[remover].
  static final ValueNotifier<String?> atual = ValueNotifier<String?>(null);

  FirebaseFirestore get _firestore => _firestoreInjetado ?? FirebaseFirestore.instance;

  static const _chaveCache = 'foto_perfil_data_uri';

  /// Acima disso a imagem não cabe com folga num documento do Firestore
  /// (limite de 1 MB; base64 infla ~33%).
  static const limiteBytes = 700 * 1024;

  DocumentReference<Map<String, dynamic>>? _doc() {
    final uid = _uidAtual();
    if (uid == null) return null;
    return _firestore.collection('usuarios').doc(uid).collection('perfil').doc('foto');
  }

  /// Data URI da foto de perfil, ou `null` se não houver. Com usuária
  /// logada, lê do Firestore e atualiza o cache; offline/deslogada, usa o
  /// cache local.
  Future<String?> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final doc = _doc();
    if (doc != null) {
      try {
        final snap = await doc.get();
        final dataUri = snap.data()?['dataUri'] as String?;
        if (dataUri == null) {
          await prefs.remove(_chaveCache);
        } else {
          await prefs.setString(_chaveCache, dataUri);
        }
        atual.value = dataUri;
        return dataUri;
      } catch (_) {
        // offline / regras ainda não deployadas — cai no cache
      }
    }
    final doCache = prefs.getString(_chaveCache);
    atual.value = doCache;
    return doCache;
  }

  /// Salva a nova foto (bytes já redimensionados/comprimidos pelo seletor).
  Future<void> salvar(Uint8List bytes, {String mime = 'image/jpeg'}) async {
    final dataUri = 'data:$mime;base64,${base64Encode(bytes)}';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveCache, dataUri);
    atual.value = dataUri;
    final doc = _doc();
    if (doc != null) {
      try {
        await doc.set({
          'dataUri': dataUri,
          'atualizadoEm': FieldValue.serverTimestamp(),
        });
      } catch (_) {
        // offline — sobe na próxima vez que salvar online
      }
    }
  }

  /// Remove a foto de perfil (Firestore + cache).
  Future<void> remover() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveCache);
    atual.value = null;
    final doc = _doc();
    if (doc != null) {
      try {
        await doc.delete();
      } catch (_) {
        // offline — some na próxima vez que remover online
      }
    }
  }
}

/// Decodifica um data URI base64 (`data:image/jpeg;base64,...`) para bytes.
/// `null` quando o texto não é um data URI base64 válido.
Uint8List? bytesDeDataUri(String? dataUri) {
  if (dataUri == null) return null;
  final virgula = dataUri.indexOf(',');
  if (!dataUri.startsWith('data:') || virgula == -1) return null;
  try {
    return base64Decode(dataUri.substring(virgula + 1));
  } catch (_) {
    return null;
  }
}
