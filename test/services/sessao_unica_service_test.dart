import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/services/controle_sessao.dart';
import 'package:app_personal_trainer/services/sessao_unica_service.dart';

class _ControleSessaoFake implements ControleSessao {
  final Map<String, String> _tokensSalvos = {};
  final Map<String, StreamController<String?>> _controllers = {};
  var _proximoToken = 0;

  StreamController<String?> _controllerPara(String uid) =>
      _controllers.putIfAbsent(uid, () => StreamController<String?>.broadcast());

  @override
  String gerarTokenSessao() => 'token-${_proximoToken++}';

  @override
  Future<void> registrarSessao(String uid, String tokenSessao) async {
    _tokensSalvos[uid] = tokenSessao;
    _controllerPara(uid).add(tokenSessao);
  }

  @override
  Stream<String?> observarTokenSessao(String uid) => _controllerPara(uid).stream;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('registrarNovaSessao registra um token no controle de sessão', () async {
    final controleSessao = _ControleSessaoFake();
    final service = SessaoUnicaService(controleSessao: controleSessao);

    await service.registrarNovaSessao('uid-1');

    expect(controleSessao._tokensSalvos['uid-1'], isNotNull);
  });

  test('observarEncerramento não emite nada enquanto a sessão local é a mais recente', () async {
    final controleSessao = _ControleSessaoFake();
    final service = SessaoUnicaService(controleSessao: controleSessao);
    await service.registrarNovaSessao('uid-1');

    final emitiuAlgumEvento = await service
        .observarEncerramento('uid-1')
        .any((_) => true)
        .timeout(const Duration(milliseconds: 300), onTimeout: () => false);

    expect(emitiuAlgumEvento, isFalse);
  });

  test('observarEncerramento emite true quando outro aparelho assume a sessão', () async {
    final controleSessao = _ControleSessaoFake();
    final service = SessaoUnicaService(controleSessao: controleSessao);
    await service.registrarNovaSessao('uid-1');

    final futuroPrimeiroEvento = service.observarEncerramento('uid-1').first;
    // Dá tempo do listener se inscrever antes de disparar o evento — o
    // controller de broadcast do fake descarta eventos sem ouvintes.
    await Future<void>.delayed(Duration.zero);

    // Outro aparelho entra na mesma conta e registra um token novo.
    await controleSessao.registrarSessao('uid-1', controleSessao.gerarTokenSessao());

    expect(await futuroPrimeiroEvento.timeout(const Duration(seconds: 2)), isTrue);
  });

  test('observarEncerramento não emite nada se nenhuma sessão local foi registrada', () async {
    final controleSessao = _ControleSessaoFake();
    final service = SessaoUnicaService(controleSessao: controleSessao);

    final emitiuAlgumEvento = await service
        .observarEncerramento('uid-sem-sessao-local')
        .any((_) => true)
        .timeout(const Duration(milliseconds: 300), onTimeout: () => false);

    expect(emitiuAlgumEvento, isFalse);
  });
}
