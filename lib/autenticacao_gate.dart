import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'onboarding_gate.dart';
import 'screens/assinatura_necessaria_screen.dart';
import 'screens/login_screen.dart';
import 'services/assinatura_repository.dart';
import 'services/auth_repository.dart';
import 'services/sessao_unica_service.dart';
import 'services/sincronizador_dados.dart';

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
    SincronizadorDados? sincronizador,
  }) : authRepositorio = authRepositorio ?? AuthRepository(),
       sessaoUnicaService = sessaoUnicaService ?? SessaoUnicaService(),
       assinaturaRepositorio = assinaturaRepositorio ?? AssinaturaRepositoryFirestore(),
       sincronizador = sincronizador ?? SincronizadorDados.instancia;

  final AuthRepository authRepositorio;
  final SessaoUnicaService sessaoUnicaService;
  final AssinaturaRepository assinaturaRepositorio;
  final SincronizadorDados sincronizador;

  @override
  State<AutenticacaoGate> createState() => _AutenticacaoGateState();
}

class _AutenticacaoGateState extends State<AutenticacaoGate> {
  StreamSubscription<bool>? _assinaturaSessao;
  String? _uidVigiado;

  Future<void>? _sincronizacao;
  String? _uidSincronizado;

  @override
  void dispose() {
    _assinaturaSessao?.cancel();
    super.dispose();
  }

  /// Puxa os dados da conta do Firestore uma vez por login (memoizado por
  /// uid) — assim a anamnese/programa/progresso seguem a usuária entre
  /// aparelhos e não somem ao limpar o navegador.
  Future<void> _sincronizarSeNecessario(String uid) {
    if (_uidSincronizado == uid && _sincronizacao != null) return _sincronizacao!;
    _uidSincronizado = uid;
    _sincronizacao = widget.sincronizador.sincronizarNoLogin(uid);
    return _sincronizacao!;
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
    _uidSincronizado = null;
    _sincronizacao = null;
    widget.sincronizador.definirUsuario(null);
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
            return FutureBuilder<void>(
              future: _sincronizarSeNecessario(usuario.uid),
              builder: (context, syncSnapshot) {
                if (syncSnapshot.connectionState != ConnectionState.done) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                return OnboardingGate(authRepositorio: widget.authRepositorio);
              },
            );
          },
        );
      },
    );
  }
}
