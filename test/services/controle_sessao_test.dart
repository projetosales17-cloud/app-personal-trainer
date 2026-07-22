import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/services/controle_sessao.dart';

void main() {
  test('gerarTokenSessao gera tokens diferentes a cada chamada', () {
    final controleSessao = ControleSessaoFirestore(firestore: FakeFirebaseFirestore());
    final tokens = {for (var i = 0; i < 20; i++) controleSessao.gerarTokenSessao()};
    expect(tokens, hasLength(20));
  });

  test('registrarSessao grava o token, e observarTokenSessao emite o valor atual', () async {
    final firestore = FakeFirebaseFirestore();
    final controleSessao = ControleSessaoFirestore(firestore: firestore);

    await controleSessao.registrarSessao('uid-1', 'token-abc');

    final doc = await firestore.collection('sessoes').doc('uid-1').get();
    expect(doc.data()?['tokenSessaoAtual'], 'token-abc');
  });

  test('observarTokenSessao emite o novo token quando a sessão é substituída', () async {
    final firestore = FakeFirebaseFirestore();
    final controleSessao = ControleSessaoFirestore(firestore: firestore);

    await controleSessao.registrarSessao('uid-1', 'token-1');

    final tokensEmitidos = <String?>[];
    final assinatura = controleSessao.observarTokenSessao('uid-1').listen(tokensEmitidos.add);
    await Future<void>.delayed(Duration.zero);

    await controleSessao.registrarSessao('uid-1', 'token-2');
    await Future<void>.delayed(Duration.zero);

    expect(tokensEmitidos, contains('token-2'));
    await assinatura.cancel();
  });
}
