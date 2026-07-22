import 'package:flutter/material.dart';

import 'autenticacao_gate.dart';
import 'services/auth_repository.dart';
import 'services/sessao_unica_service.dart';

class App extends StatelessWidget {
  App({super.key, AuthRepository? authRepositorio, SessaoUnicaService? sessaoUnicaService})
    : authRepositorio = authRepositorio ?? AuthRepository(),
      sessaoUnicaService = sessaoUnicaService ?? SessaoUnicaService();

  final AuthRepository authRepositorio;
  final SessaoUnicaService sessaoUnicaService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Trainer Online',
      // Paleta e identidade visual ainda não definidas (ver briefing do produto).
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: AutenticacaoGate(
        authRepositorio: authRepositorio,
        sessaoUnicaService: sessaoUnicaService,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
