import 'dart:convert';
import 'dart:typed_data';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/services/foto_perfil_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FotoPerfilRepository.atual.value = null;
  });

  final bytes = Uint8List.fromList(List.generate(32, (i) => i));

  test('salvar e carregar publicam a foto em FotoPerfilRepository.atual', () async {
    final repo = FotoPerfilRepository(
      firestore: FakeFirebaseFirestore(),
      uidAtual: () => 'u1',
    );
    await repo.salvar(bytes);
    expect(FotoPerfilRepository.atual.value, startsWith('data:image/jpeg;base64,'));

    await repo.remover();
    expect(FotoPerfilRepository.atual.value, isNull);
  });

  test('salvar guarda a foto no Firestore e no cache; carregar devolve o data URI', () async {
    final firestore = FakeFirebaseFirestore();
    final repo = FotoPerfilRepository(firestore: firestore, uidAtual: () => 'u1');

    await repo.salvar(bytes);

    final doc = await firestore.collection('usuarios').doc('u1').collection('perfil').doc('foto').get();
    expect(doc.data()!['dataUri'], startsWith('data:image/jpeg;base64,'));

    expect(await repo.carregar(), 'data:image/jpeg;base64,${base64Encode(bytes)}');
  });

  test('carregar usa o cache local quando não há usuária logada', () async {
    final firestore = FakeFirebaseFirestore();
    final logada = FotoPerfilRepository(firestore: firestore, uidAtual: () => 'u1');
    await logada.salvar(bytes);

    final deslogada = FotoPerfilRepository(firestore: firestore, uidAtual: () => null);
    expect(await deslogada.carregar(), isNotNull);
  });

  test('remover apaga do Firestore e do cache', () async {
    final firestore = FakeFirebaseFirestore();
    final repo = FotoPerfilRepository(firestore: firestore, uidAtual: () => 'u1');
    await repo.salvar(bytes);

    await repo.remover();

    expect(await repo.carregar(), isNull);
    final doc = await firestore.collection('usuarios').doc('u1').collection('perfil').doc('foto').get();
    expect(doc.exists, isFalse);
  });

  test('bytesDeDataUri decodifica um data URI válido e rejeita o resto', () {
    final uri = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    expect(bytesDeDataUri(uri), bytes);
    expect(bytesDeDataUri(null), isNull);
    expect(bytesDeDataUri('não é data uri'), isNull);
  });
}
