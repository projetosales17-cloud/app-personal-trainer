import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/produto.dart';
import '../services/biblioteca_produtos_repository.dart';

/// Vitrine informativa de produtos (ver briefing do produto): catálogo
/// visual integrado ao app, sem checkout embutido. O botão de compra abre
/// um link externo genérico — nada de dado pessoal é passado por URL, e
/// nenhum pagamento é processado pelo app. Enquanto não existir uma
/// loja/parceria real, o link fica nulo e o botão mostra "Em breve".
class VitrineProdutosScreen extends StatelessWidget {
  VitrineProdutosScreen({super.key, BibliotecaProdutosRepository? repositorio})
    : repositorio = repositorio ?? BibliotecaProdutosRepository();

  final BibliotecaProdutosRepository repositorio;

  Future<void> _abrirLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final abriu = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!abriu && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final produtos = repositorio.todos();

    return Scaffold(
      appBar: AppBar(title: const Text('Loja')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Catálogo informativo — preços de referência, sujeitos a '
                  'alteração. A compra é feita fora do app, em uma loja parceira.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            for (final produto in produtos)
              _ProdutoCard(produto: produto, aoComprar: _abrirLink),
          ],
        ),
      ),
    );
  }
}

class _ProdutoCard extends StatelessWidget {
  const _ProdutoCard({required this.produto, required this.aoComprar});

  final Produto produto;
  final Future<void> Function(BuildContext, String) aoComprar;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_bag_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(produto.nome, style: Theme.of(context).textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(produto.descricao),
            const SizedBox(height: 8),
            Text(
              produto.faixaPrecoReferencia,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (produto.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final tag in produto.tags)
                    Chip(label: Text(tag.label), visualDensity: VisualDensity.compact),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: produto.linkExterno == null
                    ? null
                    : () => aoComprar(context, produto.linkExterno!),
                child: Text(produto.linkExterno == null ? 'Em breve' : 'Comprar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
