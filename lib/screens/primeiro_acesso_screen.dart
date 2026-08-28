import 'package:flutter/material.dart';

import '../services/auth_repository.dart';
import '../services/primeiro_acesso_repository.dart';
import '../services/sessao_unica_service.dart';

/// Tela de "Primeiro acesso": quem acabou de comprar na Hotmart cria a
/// senha da conta (o webhook cria a conta sem senha) provando a compra
/// com o e-mail + o código da transação do recibo da Hotmart.
///
/// É o caminho à prova de falha pro risco de "comprou e ficou trancada
/// esperando o e-mail de redefinição de senha" (lento pra Outlook/Hotmail).
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
    if (!email.contains('@')) return 'Digite o e-mail que você usou na compra.';
    if (_codigoController.text.trim().isEmpty) {
      return 'Digite o código da compra (está no seu recibo da Hotmart, começa com HP).';
    }
    if (_senhaController.text.length < 6) {
      return 'A senha precisa ter pelo menos 6 caracteres.';
    }
    if (_senhaController.text != _confirmaController.text) {
      return 'As duas senhas não são iguais.';
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

    var senhaDefinida = false;
    try {
      await widget.primeiroAcessoRepositorio.definirSenha(
        email: _emailController.text.trim(),
        codigo: _codigoController.text.trim(),
        senha: _senhaController.text,
      );
      senhaDefinida = true;
      await widget.authRepositorio.entrar(
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );
      final uid = widget.authRepositorio.usuarioAtual?.uid;
      if (uid != null) {
        await widget.sessaoUnicaService.registrarNovaSessao(uid);
      }
      // O AutenticacaoGate reage ao login e troca de tela sozinho; só
      // fecho esta rota pra não ficar por cima.
      if (mounted) Navigator.of(context).pop();
    } on PrimeiroAcessoException catch (e) {
      setState(() => _erro = e.mensagem);
    } on AuthException catch (e) {
      // A senha JÁ foi criada; só o login automático falhou (rede, etc.).
      // Não deixo a pessoa presa aqui — mando de volta pro login, onde a
      // senha nova funciona.
      if (senhaDefinida) {
        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          Navigator.of(context).pop();
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Senha criada! Agora entre com seu e-mail e a nova senha.'),
            ),
          );
        }
      } else {
        setState(() => _erro = e.mensagem);
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Primeiro acesso')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Você comprou e ainda não tem senha? Crie a sua aqui.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Use o e-mail da compra e o código do recibo da Hotmart (começa com HP).',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              TextField(
                key: const Key('campo-email-primeiro-acesso'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail da compra'),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('campo-codigo-primeiro-acesso'),
                controller: _codigoController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Código da compra',
                  hintText: 'HP...',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('campo-senha-primeiro-acesso'),
                controller: _senhaController,
                obscureText: !_senhaVisivel,
                decoration: InputDecoration(
                  labelText: 'Nova senha',
                  suffixIcon: IconButton(
                    key: const Key('botao-ver-senha-primeiro-acesso'),
                    icon: Icon(_senhaVisivel ? Icons.visibility_off : Icons.visibility),
                    tooltip: _senhaVisivel ? 'Ocultar senha' : 'Mostrar senha',
                    onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('campo-confirma-primeiro-acesso'),
                controller: _confirmaController,
                obscureText: !_senhaVisivel,
                decoration: const InputDecoration(labelText: 'Repita a senha'),
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
                    : const Text('Criar senha e entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
