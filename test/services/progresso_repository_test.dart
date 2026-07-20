import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/models/registro_medidas.dart';
import 'package:app_personal_trainer/services/progresso_repository.dart';

const _pngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';

void main() {
  late Directory diretorioTemp;
  late File arquivoOrigem;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    diretorioTemp = await Directory.systemTemp.createTemp('progresso_repo_test_');
    arquivoOrigem = File('${diretorioTemp.path}/origem.png');
    await arquivoOrigem.writeAsBytes(base64Decode(_pngBase64));
  });

  tearDown(() async {
    if (await diretorioTemp.exists()) {
      await diretorioTemp.delete(recursive: true);
    }
  });

  ProgressoRepository criarRepositorio() =>
      ProgressoRepository(resolverDiretorioBase: () async => diretorioTemp);

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

  test('listarFotos retorna vazio quando nada foi registrado', () async {
    expect(await criarRepositorio().listarFotos(), isEmpty);
  });

  test('registrarFoto copia o arquivo para a pasta do app e registra a foto', () async {
    final repositorio = criarRepositorio();
    final registro = await repositorio.registrarFoto(arquivoOrigem);

    expect(await File(registro.caminhoArquivo).exists(), isTrue);
    expect(registro.caminhoArquivo, isNot(arquivoOrigem.path));

    final registros = await repositorio.listarFotos();
    expect(registros, hasLength(1));
    expect(registros.first.caminhoArquivo, registro.caminhoArquivo);
  });

  test('registrarFoto preserva a extensão do arquivo original', () async {
    final registro = await criarRepositorio().registrarFoto(arquivoOrigem);
    expect(registro.caminhoArquivo.endsWith('.png'), isTrue);
  });

  test('registrarFoto duas vezes mantém os dois arquivos e registros', () async {
    final repositorio = criarRepositorio();
    final primeiro = await repositorio.registrarFoto(arquivoOrigem);
    final segundo = await repositorio.registrarFoto(arquivoOrigem);

    expect(primeiro.caminhoArquivo, isNot(segundo.caminhoArquivo));
    expect(await repositorio.listarFotos(), hasLength(2));
  });
}
