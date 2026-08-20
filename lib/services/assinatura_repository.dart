import 'package:cloud_firestore/cloud_firestore.dart';

/// Status da assinatura de uma conta, mantido em `assinaturas/{uid}` pela
/// Cloud Function que recebe o webhook da Hotmart (ver `functions/index.js`)
/// — o app nunca escreve neste documento, só lê o próprio.
abstract class AssinaturaRepository {
  Stream<bool> observarAssinaturaAtiva(String uid);
}

class AssinaturaRepositoryFirestore implements AssinaturaRepository {
  AssinaturaRepositoryFirestore({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<bool> observarAssinaturaAtiva(String uid) {
    return _firestore
        .collection('assinaturas')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.data()?['ativa'] as bool? ?? false);
  }
}
