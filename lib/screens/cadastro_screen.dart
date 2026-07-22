import 'package:flutter/material.dart';

import '../services/auth_repository.dart';
import '../services/sessao_unica_service.dart';

class CadastroScreen extends StatefulWidget {
  CadastroScreen({super.key, AuthRepository? authRepositorio, SessaoUnicaService? sessaoUnicaService})
    : authRepositorio = authRepositorio ?? AuthRepository(),
      sessaoUnicaService = sessaoUnicaService ?? SessaoUnicaService();

  final AuthRepository authRepositorio;
  final SessaoUnicaService sessaoUnicaService;

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _aceiteTermos = false;
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  bool get _podeEnviar =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_emailController.text.trim()) &&
      _senhaController.text.length >= 6 &&
      _senhaController.text == _confirmarSenhaController.text &&
      _aceiteTermos;

  Future<void> _cadastrar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      await widget.authRepositorio.cadastrar(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: [
              TextField(
                key: const Key('campo-email-cadastro'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('campo-senha-cadastro'),
                controller: _senhaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha (mín. 6 caracteres)'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('campo-confirmar-senha-cadastro'),
                controller: _confirmarSenhaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirmar senha'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                key: const Key('checkbox-termos-cadastro'),
                contentPadding: EdgeInsets.zero,
                value: _aceiteTermos,
                onChanged: (valor) => setState(() => _aceiteTermos = valor ?? false),
                title: const Text('Li e aceito os termos de uso e a política de privacidade'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              if (_erro != null) ...[
                const SizedBox(height: 8),
                Text(_erro!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('botao-cadastrar'),
                onPressed: _carregando || !_podeEnviar ? null : _cadastrar,
                child: _carregando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Criar conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
