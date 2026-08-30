import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/services/sua_loja_repository.dart';

void main() {
  test('enviarInteresse grava um documento em interesse_sua_loja', () async {
    final firestore = FakeFirebaseFirestore();
    final repositorio = SuaLojaRepository(firestore: firestore, uidAtual: () => 'u1');

    await repositorio.enviarInteresse(
      nomeMarca: '  Marca da Bia  ',
      contato: '  11999998888  ',
      oQueVende: 'Roupa fitness',
      links: 'instagram.com/marcadabia',
    );

    final snap = await firestore.collection('interesse_sua_loja').get();
    expect(snap.docs, hasLength(1));
    final dados = snap.docs.first.data();
    expect(dados['nomeMarca'], 'Marca da Bia');
    expect(dados['contato'], '11999998888');
    expect(dados['oQueVende'], 'Roupa fitness');
    expect(dados['links'], 'instagram.com/marcadabia');
    expect(dados['uid'], 'u1');
    expect(dados['origem'], 'app');
    expect(dados.containsKey('criadoEm'), isTrue);
  });

  test('sem usuária logada, grava uid nulo', () async {
    final firestore = FakeFirebaseFirestore();
    final repositorio = SuaLojaRepository(firestore: firestore, uidAtual: () => null);

    await repositorio.enviarInteresse(
      nomeMarca: 'X',
      contato: 'x@x.com',
      oQueVende: 'Y',
      links: '',
    );

    final snap = await firestore.collection('interesse_sua_loja').get();
    expect(snap.docs.first.data()['uid'], isNull);
  });
}
