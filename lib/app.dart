import 'package:flutter/material.dart';

import 'autenticacao_gate.dart';
import 'services/assinatura_repository.dart';
import 'services/auth_repository.dart';
import 'services/sessao_unica_service.dart';
import 'services/sincronizador_dados.dart';
import 'tema.dart';

class App extends StatelessWidget {
  App({
    super.key,
    AuthRepository? authRepositorio,
    SessaoUnicaService? sessaoUnicaService,
    AssinaturaRepository? assinaturaRepositorio,
    this.sincronizador,
  }) : authRepositorio = authRepositorio ?? AuthRepository(),
       sessaoUnicaService = sessaoUnicaService ?? SessaoUnicaService(),
       assinaturaRepositorio = assinaturaRepositorio ?? AssinaturaRepositoryFirestore();

  final AuthRepository authRepositorio;
  final SessaoUnicaService sessaoUnicaService;
  final AssinaturaRepository assinaturaRepositorio;
  final SincronizadorDados? sincronizador;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MeuPersonal',
      theme: temaClaro,
      darkTheme: temaEscuro,
      themeMode: ThemeMode.system,
      home: AutenticacaoGate(
        authRepositorio: authRepositorio,
        sessaoUnicaService: sessaoUnicaService,
        assinaturaRepositorio: assinaturaRepositorio,
        sincronizador: sincronizador,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
