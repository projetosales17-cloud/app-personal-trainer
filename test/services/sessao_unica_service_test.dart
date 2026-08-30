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
  Stream<String?> observarTokenSessao(String uid) async* {
    // Como o Firestore: quem se inscreve recebe o valor atual do documento
    // na hora, e depois as mudanças.
    if (_tokensSalvos.containsKey(uid)) yield _tokensSalvos[uid];
    yield* _controllerPara(uid).stream;
  }
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

  test(
    'observarEncerramento derruba a sessão se outro aparelho assumiu enquanto este '
    'estava fechado (sem novo login neste app)',
    () async {
      final controleSessao = _ControleSessaoFake();
      final service = SessaoUnicaService(controleSessao: controleSessao);

      // Token local de um login anterior nesta instalação...
      SharedPreferences.setMockInitialValues({'token_sessao_local': 'token-deste-aparelho'});
      // ...mas o Firestore já aponta para outro aparelho. Nenhum
      // registrarNovaSessao acontece aqui (o app só reabriu).
      await controleSessao.registrarSessao('uid-1', 'token-de-outro-aparelho');

      final primeiroEvento = await service
          .observarEncerramento('uid-1')
          .first
          .timeout(const Duration(seconds: 2));

      expect(primeiroEvento, isTrue);
    },
  );

  test(
    'observarEncerramento não derruba a sessão recém-registrada quando a vigilância '
    'já está ativa ao registrar (regressão do auto-logout)',
    () async {
      final controleSessao = _ControleSessaoFake();
      final service = SessaoUnicaService(controleSessao: controleSessao);

      // Login anterior nesta mesma instalação: já existe um token local
      // salvo e o Firestore ainda aponta pra ele.
      SharedPreferences.setMockInitialValues({'token_sessao_local': 'token-antigo'});
      await controleSessao.registrarSessao('uid-1', 'token-antigo');

      // A vigilância começa (o gate reage ao authStateChanges do login)
      // ANTES de registrarNovaSessao concluir.
      final emitiuAlgumEvento = service
          .observarEncerramento('uid-1')
          .any((_) => true)
          .timeout(const Duration(milliseconds: 400), onTimeout: () => false);

      await Future<void>.delayed(const Duration(milliseconds: 20));
      // Só agora o login registra a sessão nova, com a vigilância já rodando.
      await service.registrarNovaSessao('uid-1');

      expect(await emitiuAlgumEvento, isFalse); // não pode ter se desconectado sozinho
    },
  );
}
