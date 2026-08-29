import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/models/registro_foto.dart';
import 'package:app_personal_trainer/models/registro_medidas.dart';
import 'package:app_personal_trainer/services/progresso_repository.dart';

const _pngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';

void main() {
  late Directory diretorioTemp;
  late File arquivoOrigem;
  late Uint8List bytesFoto;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    diretorioTemp = await Directory.systemTemp.createTemp('progresso_repo_test_');
    arquivoOrigem = File('${diretorioTemp.path}/origem.png');
    bytesFoto = base64Decode(_pngBase64);
    await arquivoOrigem.writeAsBytes(bytesFoto);
  });

  tearDown(() async {
    if (await diretorioTemp.exists()) {
      await diretorioTemp.delete(recursive: true);
    }
  });

  // gerarMiniaturaVideo real faz chamada de platform channel — sem
  // implementação nativa disponível no ambiente de teste. Injetamos um fake
  // que não faz nada. `uidAtual: null` mantém as fotos no cache local (sem
  // Firestore); os testes de sync injetam um FakeFirebaseFirestore + uid.
  ProgressoRepository criarRepositorio() => ProgressoRepository(
    resolverDiretorioBase: () async => diretorioTemp,
    gerarMiniaturaVideo: (_, _) async => null,
    uidAtual: () => null,
  );

  test('listarPesos e ultimoPeso retornam vazio/nulo quando nada foi registrado', () async {
    final repositorio = ProgressoRepository();
    expect(await repositorio.listarPesos(), isEmpty);
    expect(await repositorio.ultimoPeso(), isNull);
  });

  test('registrarPeso adiciona um registro que pode ser lido de volta', () async {
    final repositorio = ProgressoRepository();
    await repositorio.registrarPeso(70, data: DateTime(2026, 1, 1));

    final registros = await repositorio.listarPesos();
    expect(registros, hasLength(1));
    expect(registros.first.pesoKg, 70);
  });

  test('ultimoPeso retorna o registro mais recente, independente da ordem de inserção', () async {
    final repositorio = ProgressoRepository();
    await repositorio.registrarPeso(72, data: DateTime(2026, 1, 10));
    await repositorio.registrarPeso(70, data: DateTime(2026, 1, 1));
    await repositorio.registrarPeso(71, data: DateTime(2026, 1, 5));

    final ultimo = await repositorio.ultimoPeso();
    expect(ultimo!.pesoKg, 72);
    expect(ultimo.data, DateTime(2026, 1, 10));
  });

  test('listarPesos retorna os registros ordenados por data crescente', () async {
    final repositorio = ProgressoRepository();
    await repositorio.registrarPeso(72, data: DateTime(2026, 1, 10));
    await repositorio.registrarPeso(70, data: DateTime(2026, 1, 1));

    final registros = await repositorio.listarPesos();
    expect(registros.map((r) => r.pesoKg), [70, 72]);
  });

  test('listarMedidas retorna vazio quando nada foi registrado', () async {
    final repositorio = ProgressoRepository();
    expect(await repositorio.listarMedidas(), isEmpty);
  });

  test('registrarMedidas adiciona um registro que pode ser lido de volta', () async {
    final repositorio = ProgressoRepository();
    await repositorio.registrarMedidas(
      RegistroMedidas(data: DateTime(2026, 1, 1), cinturaCm: 80, quadrilCm: 100),
    );

    final registros = await repositorio.listarMedidas();
    expect(registros, hasLength(1));
    expect(registros.first.cinturaCm, 80);
    expect(registros.first.quadrilCm, 100);
  });

  test('listarMedidas retorna os registros ordenados por data crescente', () async {
    final repositorio = ProgressoRepository();
    await repositorio.registrarMedidas(RegistroMedidas(data: DateTime(2026, 1, 10), bracoCm: 32));
    await repositorio.registrarMedidas(RegistroMedidas(data: DateTime(2026, 1, 1), bracoCm: 30));

    final registros = await repositorio.listarMedidas();
    expect(registros.map((r) => r.bracoCm), [30, 32]);
  });

  group('fotos — sem usuária logada (cache local)', () {
    test('listarFotos retorna vazio quando nada foi registrado', () async {
      expect(await criarRepositorio().listarFotos(), isEmpty);
    });

    test('registrarFoto guarda a imagem como data URI base64 e lê de volta', () async {
      final repositorio = criarRepositorio();
      final registro = await repositorio.registrarFoto(bytesFoto);

      expect(registro.dataUri, startsWith('data:image/jpeg;base64,'));
      expect(registro.bytes, bytesFoto);
      expect(registro.id, startsWith('local_'));

      final registros = await repositorio.listarFotos();
      expect(registros, hasLength(1));
      expect(registros.first.dataUri, registro.dataUri);
    });

    test('registrarFoto duas vezes mantém os dois registros, em ordem de data', () async {
      final repositorio = criarRepositorio();
      await repositorio.registrarFoto(bytesFoto);
      await repositorio.registrarFoto(bytesFoto);

      final registros = await repositorio.listarFotos();
      expect(registros, hasLength(2));
      expect(registros.first.data.compareTo(registros.last.data), lessThanOrEqualTo(0));
    });

    test('removerFoto tira do cache local', () async {
      final repositorio = criarRepositorio();
      final foto = await repositorio.registrarFoto(bytesFoto);
      await repositorio.removerFoto(foto.id);
      expect(await repositorio.listarFotos(), isEmpty);
    });

    test('registrarFoto guarda o ângulo (pose) e lê de volta', () async {
      final repositorio = criarRepositorio();
      await repositorio.registrarFoto(bytesFoto, pose: PoseFoto.costas);
      final fotos = await repositorio.listarFotos();
      expect(fotos.single.pose, PoseFoto.costas);
    });

    test('pose padrão é livre', () async {
      final repositorio = criarRepositorio();
      await repositorio.registrarFoto(bytesFoto);
      expect((await repositorio.listarFotos()).single.pose, PoseFoto.livre);
    });
  });

  group('fotos — com usuária logada (Firestore)', () {
    late FakeFirebaseFirestore firestore;
    ProgressoRepository criarRepositorioFs() => ProgressoRepository(
      resolverDiretorioBase: () async => diretorioTemp,
      gerarMiniaturaVideo: (_, _) async => null,
      firestore: firestore,
      uidAtual: () => 'u1',
    );

    setUp(() => firestore = FakeFirebaseFirestore());

    test('registrarFoto grava um documento em usuarios/{uid}/fotos_progresso', () async {
      final repositorio = criarRepositorioFs();
      await repositorio.registrarFoto(bytesFoto);

      final snap =
          await firestore.collection('usuarios').doc('u1').collection('fotos_progresso').get();
      expect(snap.docs, hasLength(1));
      expect(snap.docs.first.data()['dataUri'], startsWith('data:image/jpeg;base64,'));
    });

    test('listarFotos lê do Firestore ordenado por data, com o ângulo', () async {
      final repositorio = criarRepositorioFs();
      await repositorio.registrarFoto(bytesFoto, pose: PoseFoto.frente);
      await repositorio.registrarFoto(bytesFoto, pose: PoseFoto.lado);

      final registros = await repositorio.listarFotos();
      expect(registros, hasLength(2));
      expect(registros.first.id, isNot(startsWith('local_')));
      expect(registros.map((f) => f.pose), [PoseFoto.frente, PoseFoto.lado]);
    });

    test('removerFoto apaga o documento do Firestore', () async {
      final repositorio = criarRepositorioFs();
      final foto = await repositorio.registrarFoto(bytesFoto);
      await repositorio.removerFoto(foto.id);

      final snap =
          await firestore.collection('usuarios').doc('u1').collection('fotos_progresso').get();
      expect(snap.docs, isEmpty);
      expect(await repositorio.listarFotos(), isEmpty);
    });

    test('outra usuária não enxerga as fotos (subcoleção por uid)', () async {
      await criarRepositorioFs().registrarFoto(bytesFoto);

      final outra = ProgressoRepository(
        resolverDiretorioBase: () async => diretorioTemp,
        gerarMiniaturaVideo: (_, _) async => null,
        firestore: firestore,
        uidAtual: () => 'u2',
      );
      expect(await outra.listarFotos(), isEmpty);
    });
  });

  test('listarVideos retorna vazio quando nada foi registrado', () async {
    expect(await criarRepositorio().listarVideos(), isEmpty);
  });

  test('registrarVideo copia o arquivo para a pasta do app e registra o vídeo', () async {
    final repositorio = criarRepositorio();
    final registro = await repositorio.registrarVideo(arquivoOrigem);

    expect(await File(registro.caminhoArquivo).exists(), isTrue);
    expect(registro.caminhoArquivo, isNot(arquivoOrigem.path));
    expect(registro.caminhoArquivo, contains('videos_progresso'));

    final registros = await repositorio.listarVideos();
    expect(registros, hasLength(1));
  });

  test('registrarVideo grava o caminho retornado pelo gerador de miniatura injetado', () async {
    final repositorio = ProgressoRepository(
      resolverDiretorioBase: () async => diretorioTemp,
      gerarMiniaturaVideo: (caminhoVideo, pastaDestino) async => '$pastaDestino/miniatura.jpg',
      uidAtual: () => null,
    );

    final registro = await repositorio.registrarVideo(arquivoOrigem);

    expect(registro.caminhoMiniatura, contains('miniaturas_videos_progresso'));
    expect(registro.caminhoMiniatura, endsWith('miniatura.jpg'));

    final registros = await repositorio.listarVideos();
    expect(registros.first.caminhoMiniatura, registro.caminhoMiniatura);
  });

  test('fotos e vídeos ficam em listas independentes', () async {
    final repositorio = criarRepositorio();
    await repositorio.registrarFoto(bytesFoto);
    await repositorio.registrarVideo(arquivoOrigem);

    expect(await repositorio.listarFotos(), hasLength(1));
    expect(await repositorio.listarVideos(), hasLength(1));
  });
}
