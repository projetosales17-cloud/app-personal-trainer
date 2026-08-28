import 'package:flutter/material.dart';

import '../services/auth_repository.dart';
import '../services/primeiro_acesso_repository.dart';
import '../services/sessao_unica_service.dart';
import 'primeiro_acesso_screen.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({
    super.key,
    AuthRepository? authRepositorio,
    SessaoUnicaService? sessaoUnicaService,
    PrimeiroAcessoRepository? primeiroAcessoRepositorio,
    Uri? uriInicial,
  }) : authRepositorio = authRepositorio ?? AuthRepository(),
       sessaoUnicaService = sessaoUnicaService ?? SessaoUnicaService(),
       primeiroAcessoRepositorio = primeiroAcessoRepositorio ?? PrimeiroAcessoRepository(),
       uriInicial = uriInicial ?? Uri.base;

  final AuthRepository authRepositorio;
  final SessaoUnicaService sessaoUnicaService;
  final PrimeiroAcessoRepository primeiroAcessoRepositorio;

  /// URL de abertura do app. Se vier `?acesso=1` (link do e-mail de
  /// boas-vindas), a tela já abre o "Primeiro acesso" com e-mail e código
  /// preenchidos.
  final Uri uriInicial;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;
  bool _senhaVisivel = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    final params = widget.uriInicial.queryParameters;
    if (params['acesso'] == '1') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _abrirPrimeiroAcesso(
            emailInicial: params['email'],
            codigoInicial: params['tx'],
          );
        }
      });
    }
  }

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

  void _abrirPrimeiroAcesso({String? emailInicial, String? codigoInicial}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PrimeiroAcessoScreen(
          authRepositorio: widget.authRepositorio,
          sessaoUnicaService: widget.sessaoUnicaService,
          primeiroAcessoRepositorio: widget.primeiroAcessoRepositorio,
          emailInicial:
              (emailInicial != null && emailInicial.isNotEmpty)
                  ? emailInicial
                  : _emailController.text.trim(),
          codigoInicial: codigoInicial,
        ),
      ),
    );
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
                obscureText: !_senhaVisivel,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  suffixIcon: IconButton(
                    key: const Key('botao-ver-senha-login'),
                    icon: Icon(_senhaVisivel ? Icons.visibility_off : Icons.visibility),
                    tooltip: _senhaVisivel ? 'Ocultar senha' : 'Mostrar senha',
                    onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
                  ),
                ),
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
              TextButton(
                key: const Key('botao-primeiro-acesso'),
                onPressed: _carregando ? null : () => _abrirPrimeiroAcesso(),
                child: const Text('Primeiro acesso (comprei e não tenho senha)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
