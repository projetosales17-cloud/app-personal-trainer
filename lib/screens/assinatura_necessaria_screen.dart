import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/auth_repository.dart';

/// Mostrada quando a conta está autenticada mas sem assinatura ativa em
/// `assinaturas/{uid}` (ver `AssinaturaRepository`). A tela é reativa: assim
/// que o webhook da Hotmart liberar o acesso, o app avança sozinho — não
/// precisa de botão de "atualizar".
class AssinaturaNecessariaScreen extends StatelessWidget {
  const AssinaturaNecessariaScreen({super.key, required this.authRepositorio});

  final AuthRepository authRepositorio;

  // TODO: atualizar com o link real assim que o produto brasileiro for
  // criado no Hotmart (ver produto MiPersonal/México como referência).
  static const _linkCompra = 'https://go.hotmart.com/PENDENTE-PRODUTO-BR';

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
              Text(
                'Você precisa de uma assinatura ativa',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              const Text(
                'Não encontramos uma assinatura ativa associada à sua conta. '
                'Se você já comprou, esta tela se atualiza sozinha assim que '
                'o pagamento for confirmado.',
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('botao-assinar'),
                onPressed: () => launchUrl(
                  Uri.parse(_linkCompra),
                  mode: LaunchMode.externalApplication,
                ),
                child: const Text('Assinar agora'),
              ),
              const SizedBox(height: 12),
              TextButton(
                key: const Key('botao-sair-assinatura'),
                onPressed: () => authRepositorio.sair(),
                child: const Text('Sair da conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
