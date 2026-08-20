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

  static const _linkCompra = 'https://go.hotmart.com/N107243605R';

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
                'Necesitas una suscripción activa',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              const Text(
                'No encontramos una suscripción activa asociada a tu cuenta. '
                'Si ya compraste, esta pantalla se actualiza sola en cuanto '
                'se confirme el pago.',
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('botao-comprar-suscripcion'),
                onPressed: () => launchUrl(
                  Uri.parse(_linkCompra),
                  mode: LaunchMode.externalApplication,
                ),
                child: const Text('Suscribirme ahora'),
              ),
              const SizedBox(height: 12),
              TextButton(
                key: const Key('botao-cerrar-sesion'),
                onPressed: () => authRepositorio.sair(),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
