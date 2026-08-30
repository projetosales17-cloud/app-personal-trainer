import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Coleta o interesse das usuárias que querem anunciar a própria loja no
/// espaço "Sua Loja" (ainda em construção — ver `SuaLojaScreen`).
///
/// Grava um documento em `interesse_sua_loja/{autoId}`. O cliente só pode
/// criar (nunca ler/editar/apagar — as regras do Firestore garantem isso);
/// o fundador lê os interesses pelo console. Sem cobrança, sem publicação:
/// é só uma lista de espera para medir demanda antes de construir o
/// marketplace de verdade.
class SuaLojaRepository {
  SuaLojaRepository({FirebaseFirestore? firestore, String? Function()? uidAtual})
    : _firestoreInjetado = firestore,
      _uidAtual = uidAtual ?? _uidLogado;

  final FirebaseFirestore? _firestoreInjetado;
  final String? Function() _uidAtual;

  FirebaseFirestore get _firestore => _firestoreInjetado ?? FirebaseFirestore.instance;

  static String? _uidLogado() {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  Future<void> enviarInteresse({
    required String nomeMarca,
    required String contato,
    required String oQueVende,
    required String links,
  }) async {
    await _firestore.collection('interesse_sua_loja').add({
      'criadoEm': FieldValue.serverTimestamp(),
      'uid': _uidAtual(),
      'nomeMarca': nomeMarca.trim(),
      'contato': contato.trim(),
      'oQueVende': oQueVende.trim(),
      'links': links.trim(),
      'origem': 'app',
    });
  }
}
