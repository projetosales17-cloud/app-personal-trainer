import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'onboarding_gate.dart';
import 'screens/assinatura_necessaria_screen.dart';
import 'screens/login_screen.dart';
import 'services/assinatura_repository.dart';
import 'services/auth_repository.dart';
import 'services/sessao_unica_service.dart';

/// Primeiro portão do app: decide entre a tela de login e o restante do
/// app (onboarding/anamnese + navegação principal), conforme o estado de
/// autenticação. Depois de autenticada, também vigia se a sessão foi
/// assumida por outro aparelho ("1 licença = 1 usuária", ver briefing do
/// produto) e força saída se sim.
class AutenticacaoGate extends StatefulWidget {
  AutenticacaoGate({
    super.key,
    AuthRepository? authRepositorio,
    SessaoUnicaService? sessaoUnicaService,
    AssinaturaRepository? assinaturaRepositorio,
  }) : authRepositorio = authRepositorio ?? AuthRepository(),
       sessaoUnicaService = sessaoUnicaService ?? SessaoUnicaService(),
       assinaturaRepositorio = assinaturaRepositorio ?? AssinaturaRepositoryFirestore();

  final AuthRepository authRepositorio;
  final SessaoUnicaService sessaoUnicaService;
  final AssinaturaRepository assinaturaRepositorio;

  @override
  State<AutenticacaoGate> createState() => _AutenticacaoGateState();
}

class _AutenticacaoGateState extends State<AutenticacaoGate> {
  StreamSubscription<bool>? _assinaturaSessao;
  String? _uidVigiado;

  @override
  void dispose() {
    _assinaturaSessao?.cancel();
    super.dispose();
  }

  void _vigiarSessao(String uid) {
    if (_uidVigiado == uid) return;
    _assinaturaSessao?.cancel();
    _uidVigiado = uid;
    _assinaturaSessao = widget.sessaoUnicaService.observarEncerramento(uid).listen((
      encerrada,
    ) async {
      if (!encerrada) return;
      await widget.authRepositorio.sair();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu cuenta fue accedida desde otro dispositivo. Fuiste desconectada.'),
        ),
      );
    });
  }

  void _pararDeVigiar() {
    _assinaturaSessao?.cancel();
    _assinaturaSessao = null;
    _uidVigiado = null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: widget.authRepositorio.mudancasDeUsuario,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final usuario = snapshot.data;
        if (usuario == null) {
          _pararDeVigiar();
          return LoginScreen(
            authRepositorio: widget.authRepositorio,
            sessaoUnicaService: widget.sessaoUnicaService,
          );
        }

        _vigiarSessao(usuario.uid);
        return StreamBuilder<bool>(
          stream: widget.assinaturaRepositorio.observarAssinaturaAtiva(usuario.uid),
          builder: (context, assinaturaSnapshot) {
            if (assinaturaSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (assinaturaSnapshot.data != true) {
              return AssinaturaNecessariaScreen(authRepositorio: widget.authRepositorio);
            }
            return OnboardingGate(authRepositorio: widget.authRepositorio);
          },
        );
      },
    );
  }
}
