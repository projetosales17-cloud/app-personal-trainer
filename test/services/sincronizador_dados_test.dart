import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/services/anamnese_repository.dart';
import 'package:app_personal_trainer/services/preferencias_repository.dart';
import 'package:app_personal_trainer/services/sincronizador_dados.dart';
import 'package:app_personal_trainer/models/anamnese.dart';

void main() {
  late SincronizadorDados original;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    original = SincronizadorDados.instancia;
  });

  tearDown(() {
    SincronizadorDados.instancia = original;
    original.definirUsuario(null);
  });

  test('no login, dados só do servidor descem para o aparelho novo', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('usuarios').doc('uid-1').set({
      'anamnese': '{"idade":42}',
      'anamnese__ts': 1000,
      'notificacoes_ativadas': false,
      'notificacoes_ativadas__ts': 1000,
    });

    final sinc = SincronizadorDados(firestore: firestore);
    await sinc.sincronizarNoLogin('uid-1');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('anamnese'), '{"idade":42}');
    expect(prefs.getBool('notificacoes_ativadas'), isFalse);
  });

  test('no login, dados só locais sobem para o servidor', () async {
    SharedPreferences.setMockInitialValues({
      'anamnese': '{"idade":30}',
      'dias_semana_treino': ['2', '5'],
    });
    final firestore = FakeFirebaseFirestore();
    final sinc = SincronizadorDados(firestore: firestore);

    await sinc.sincronizarNoLogin('uid-1');

    final doc = await firestore.collection('usuarios').doc('uid-1').get();
    expect(doc.data()!['anamnese'], '{"idade":30}');
    expect(doc.data()!['dias_semana_treino'], ['2', '5']);
  });

  test('o timestamp mais recente vence quando os dois lados têm dados', () async {
    SharedPreferences.setMockInitialValues({
      'anamnese': '{"local":true}',
      'anamnese__ts': 5000,
    });
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('usuarios').doc('uid-1').set({
      'anamnese': '{"servidor":true}',
      'anamnese__ts': 1000,
    });

    final sinc = SincronizadorDados(firestore: firestore);
    await sinc.sincronizarNoLogin('uid-1');

    // Local é mais novo -> mantém o local e sobe pro servidor.
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('anamnese'), '{"local":true}');
    final doc = await firestore.collection('usuarios').doc('uid-1').get();
    expect(doc.data()!['anamnese'], '{"local":true}');
  });

  test('aposEscrita envia a chave quando há usuário logado', () async {
    final firestore = FakeFirebaseFirestore();
    final sinc = SincronizadorDados(firestore: firestore);
    SincronizadorDados.instancia = sinc;
    await sinc.sincronizarNoLogin('uid-1'); // fixa o usuário

    await AnamneseRepository().salvar(
      const Anamnese(
        idade: 33,
        alturaCm: 168,
        pesoAtualKg: 62,
        objetivoPrincipal: Objetivo.emagrecimento,
        nivelAtividade: NivelAtividade.moderado,
        frequenciaSemanalDias: 3,
      ),
    );

    final doc = await firestore.collection('usuarios').doc('uid-1').get();
    expect(doc.data()!['anamnese'], contains('"idade":33'));
    expect(doc.data()!['anamnese__ts'], isA<int>());
  });

  test('sem usuário logado, aposEscrita não toca no Firestore (só carimba local)', () async {
    final firestore = FakeFirebaseFirestore();
    SincronizadorDados.instancia = SincronizadorDados(firestore: firestore);

    await PreferenciasRepository().definirNotificacoesAtivadas(false);

    final docs = await firestore.collection('usuarios').get();
    expect(docs.docs, isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('notificacoes_ativadas__ts'), isNotNull);
  });
}
