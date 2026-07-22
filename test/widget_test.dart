import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/app.dart';
import 'package:app_personal_trainer/services/auth_repository.dart';
import 'package:app_personal_trainer/services/controle_sessao.dart';
import 'package:app_personal_trainer/services/sessao_unica_service.dart';

/// Fake que não escreve em nenhum lugar real — usado nos testes em que o
/// controle de sessão única não é o foco (ver test/autenticacao_gate_test.dart
/// para os testes dedicados a essa lógica).
class _ControleSessaoSemEfeito implements ControleSessao {
  @override
  String gerarTokenSessao() => 'token-fake';

  @override
  Future<void> registrarSessao(String uid, String tokenSessao) async {}

  @override
  Stream<String?> observarTokenSessao(String uid) => const Stream.empty();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Sem login, mostra a tela de entrar', (tester) async {
    final authRepositorio = AuthRepository(auth: MockFirebaseAuth());
    final sessaoUnicaService = SessaoUnicaService(controleSessao: _ControleSessaoSemEfeito());

    await tester.pumpWidget(
      App(authRepositorio: authRepositorio, sessaoUnicaService: sessaoUnicaService),
    );
    await tester.pump();

    expect(find.text('Entrar'), findsWidgets);
  });

  testWidgets('Logada sem anamnese salva, o app abre no onboarding', (tester) async {
    final authRepositorio = AuthRepository(
      auth: MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'uid-1', email: 'usuaria@example.com'),
      ),
    );
    final sessaoUnicaService = SessaoUnicaService(controleSessao: _ControleSessaoSemEfeito());

    await tester.pumpWidget(
      App(authRepositorio: authRepositorio, sessaoUnicaService: sessaoUnicaService),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bem-vinda!'), findsOneWidget);
  });

  testWidgets('Logada com anamnese já salva, o app vai direto para a navegação principal', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'anamnese':
          '{"idade":30,"alturaCm":170.0,"pesoAtualKg":65.0,"pesoDesejadoKg":null,'
          '"objetivoPrincipal":"emagrecimento","cirurgiaBariatrica":false,'
          '"tipoCirurgiaBariatrica":null,"mesesDesdeCirurgia":null,'
          '"condicaoHormonal":"Nenhuma","restricoesAlimentares":[],"lesoesLimitacoes":[],'
          '"nivelAtividade":"moderado","frequenciaSemanalDias":3,"regioesPriorizadas":[]}',
    });
    final authRepositorio = AuthRepository(
      auth: MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'uid-1', email: 'usuaria@example.com'),
      ),
    );
    final sessaoUnicaService = SessaoUnicaService(controleSessao: _ControleSessaoSemEfeito());

    await tester.pumpWidget(
      App(authRepositorio: authRepositorio, sessaoUnicaService: sessaoUnicaService),
    );
    await tester.pumpAndSettle();

    expect(find.text('Início'), findsWidgets);
    expect(find.byType(NavigationDestination), findsNWidgets(7));
  });
}
