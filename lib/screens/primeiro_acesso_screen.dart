import 'package:flutter/material.dart';

import '../services/auth_repository.dart';
import '../services/primeiro_acesso_repository.dart';
import '../services/sessao_unica_service.dart';

/// Pantalla de "Primer acceso": quien acaba de comprar en Hotmart crea la
/// contraseña de la cuenta (el webhook crea la cuenta sin contraseña)
/// probando la compra con el correo + el código de la transacción del
/// recibo de Hotmart.
///
/// Es el camino a prueba de fallos para el riesgo de "compré y me quedé
/// bloqueada esperando el correo de restablecimiento de contraseña"
/// (lento para Outlook/Hotmail).
class PrimeiroAcessoScreen extends StatefulWidget {
  PrimeiroAcessoScreen({
    super.key,
    AuthRepository? authRepositorio,
    SessaoUnicaService? sessaoUnicaService,
    PrimeiroAcessoRepository? primeiroAcessoRepositorio,
    this.emailInicial,
    this.codigoInicial,
  }) : authRepositorio = authRepositorio ?? AuthRepository(),
       sessaoUnicaService = sessaoUnicaService ?? SessaoUnicaService(),
       primeiroAcessoRepositorio =
           primeiroAcessoRepositorio ?? PrimeiroAcessoRepository();

  final AuthRepository authRepositorio;
  final SessaoUnicaService sessaoUnicaService;
  final PrimeiroAcessoRepository primeiroAcessoRepositorio;
  final String? emailInicial;
  final String? codigoInicial;

  @override
  State<PrimeiroAcessoScreen> createState() => _PrimeiroAcessoScreenState();
}

class _PrimeiroAcessoScreenState extends State<PrimeiroAcessoScreen> {
  late final _emailController = TextEditingController(text: widget.emailInicial ?? '');
  late final _codigoController = TextEditingController(text: widget.codigoInicial ?? '');
  final _senhaController = TextEditingController();
  final _confirmaController = TextEditingController();

  bool _carregando = false;
  bool _senhaVisivel = false;
  String? _erro;

  @override
  void dispose() {
    _emailController.dispose();
    _codigoController.dispose();
    _senhaController.dispose();
    _confirmaController.dispose();
    super.dispose();
  }

  String? _validar() {
    final email = _emailController.text.trim();
    if (!email.contains('@')) return 'Escribe el correo que usaste en la compra.';
    if (_codigoController.text.trim().isEmpty) {
      return 'Escribe el código de compra (está en tu recibo de Hotmart, empieza con HP).';
    }
    if (_senhaController.text.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    if (_senhaController.text != _confirmaController.text) {
      return 'Las dos contraseñas no coinciden.';
    }
    return null;
  }

  Future<void> _criarSenha() async {
    final erroValidacao = _validar();
    if (erroValidacao != null) {
      setState(() => _erro = erroValidacao);
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      await widget.primeiroAcessoRepositorio.definirSenha(
        email: _emailController.text.trim(),
        codigo: _codigoController.text.trim(),
        senha: _senhaController.text,
      );
      await widget.authRepositorio.entrar(
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );
      final uid = widget.authRepositorio.usuarioAtual?.uid;
      if (uid != null) {
        await widget.sessaoUnicaService.registrarNovaSessao(uid);
      }
      // El AutenticacaoGate reacciona al login y cambia de pantalla solo;
      // solo cierro esta ruta para que no quede encima.
      if (mounted) Navigator.of(context).pop();
    } on PrimeiroAcessoException catch (e) {
      setState(() => _erro = e.mensagem);
    } on AuthException catch (e) {
      setState(() => _erro = e.mensagem);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Primer acceso')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '¿Compraste y todavía no tienes contraseña? Créala aquí.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Usa el correo de la compra y el código del recibo de Hotmart (empieza con HP).',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              TextField(
                key: const Key('campo-email-primeiro-acesso'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Correo de la compra'),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('campo-codigo-primeiro-acesso'),
                controller: _codigoController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Código de compra',
                  hintText: 'HP...',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('campo-senha-primeiro-acesso'),
                controller: _senhaController,
                obscureText: !_senhaVisivel,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  suffixIcon: IconButton(
                    key: const Key('botao-ver-senha-primeiro-acesso'),
                    icon: Icon(_senhaVisivel ? Icons.visibility_off : Icons.visibility),
                    tooltip: _senhaVisivel ? 'Ocultar contraseña' : 'Mostrar contraseña',
                    onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('campo-confirma-primeiro-acesso'),
                controller: _confirmaController,
                obscureText: !_senhaVisivel,
                decoration: const InputDecoration(labelText: 'Repite la contraseña'),
              ),
              if (_erro != null) ...[
                const SizedBox(height: 12),
                Text(_erro!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('botao-criar-senha-primeiro-acesso'),
                onPressed: _carregando ? null : _criarSenha,
                child: _carregando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Crear contraseña y entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
