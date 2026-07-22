import 'package:flutter/material.dart';

import '../services/auth_repository.dart';
import '../services/sessao_unica_service.dart';
import 'cadastro_screen.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key, AuthRepository? authRepositorio, SessaoUnicaService? sessaoUnicaService})
    : authRepositorio = authRepositorio ?? AuthRepository(),
      sessaoUnicaService = sessaoUnicaService ?? SessaoUnicaService();

  final AuthRepository authRepositorio;
  final SessaoUnicaService sessaoUnicaService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      await widget.authRepositorio.entrar(
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );
      final uid = widget.authRepositorio.usuarioAtual?.uid;
      if (uid != null) {
        await widget.sessaoUnicaService.registrarNovaSessao(uid);
      }
    } on AuthException catch (e) {
      setState(() => _erro = e.mensagem);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _esqueciSenha() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _erro = 'Digite seu e-mail para redefinir a senha.');
      return;
    }
    try {
      await widget.authRepositorio.redefinirSenha(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail de redefinição de senha enviado.')),
      );
    } on AuthException catch (e) {
      setState(() => _erro = e.mensagem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Entrar', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),
              TextField(
                key: const Key('campo-email-login'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail'),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('campo-senha-login'),
                controller: _senhaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha'),
              ),
              if (_erro != null) ...[
                const SizedBox(height: 12),
                Text(_erro!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('botao-entrar'),
                onPressed: _carregando ? null : _entrar,
                child: _carregando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Entrar'),
              ),
              TextButton(
                key: const Key('botao-esqueci-senha'),
                onPressed: _carregando ? null : _esqueciSenha,
                child: const Text('Esqueci minha senha'),
              ),
              const Divider(height: 32),
              TextButton(
                key: const Key('botao-ir-para-cadastro'),
                onPressed: _carregando
                    ? null
                    : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CadastroScreen(
                            authRepositorio: widget.authRepositorio,
                            sessaoUnicaService: widget.sessaoUnicaService,
                          ),
                        ),
                      ),
                child: const Text('Ainda não tem conta? Cadastre-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
