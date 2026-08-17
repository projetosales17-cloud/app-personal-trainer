import 'package:flutter/material.dart';

/// Mensagem exibida no lugar de funcionalidades que dependem de
/// armazenamento de arquivos locais (fotos/vídeos de progresso), ainda não
/// suportado na versão web do app.
class IndisponivelNaWeb extends StatelessWidget {
  const IndisponivelNaWeb({super.key, required this.mensagem});

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
