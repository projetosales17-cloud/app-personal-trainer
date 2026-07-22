import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Abstração para registrar/observar a sessão ativa de uma conta —
/// permite testar a lógica de "1 licença = 1 usuária" com um fake, sem
/// depender do Firestore real (indisponível no ambiente de teste). Mesmo
/// padrão já usado para notificações (AgendadorNotificacoes).
abstract class ControleSessao {
  String gerarTokenSessao();
  Future<void> registrarSessao(String uid, String tokenSessao);
  Stream<String?> observarTokenSessao(String uid);
}

/// Implementação real via Firestore. Cada conta tem um único documento em
/// `sessoes/{uid}` guardando o token da sessão mais recente — entrar em um
/// novo aparelho sobrescreve o token, permitindo que o aparelho anterior
/// detecte a troca (ver briefing do produto: "1 licença = 1 usuária").
class ControleSessaoFirestore implements ControleSessao {
  ControleSessaoFirestore({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  String gerarTokenSessao() {
    final aleatorio = Random.secure();
    return List.generate(24, (_) => aleatorio.nextInt(16).toRadixString(16)).join();
  }

  @override
  Future<void> registrarSessao(String uid, String tokenSessao) {
    return _firestore.collection('sessoes').doc(uid).set({
      'tokenSessaoAtual': tokenSessao,
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<String?> observarTokenSessao(String uid) {
    return _firestore
        .collection('sessoes')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.data()?['tokenSessaoAtual'] as String?);
  }
}
