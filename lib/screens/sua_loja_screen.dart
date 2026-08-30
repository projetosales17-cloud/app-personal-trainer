import 'package:flutter/material.dart';

import '../services/sua_loja_repository.dart';

/// "Sua Loja" — espaço em construção onde, em breve, as usuárias que também
/// vendem vão poder divulgar a própria marca para todas as outras. Por
/// enquanto a tela é só um teaser + lista de espera: mede a demanda antes
/// de construir cobrança, moderação e vitrine de verdade. Nada é publicado
/// e nada é cobrado aqui.
class SuaLojaScreen extends StatelessWidget {
  SuaLojaScreen({super.key, SuaLojaRepository? repositorio})
    : repositorio = repositorio ?? SuaLojaRepository();

  final SuaLojaRepository repositorio;

  Future<void> _abrirFormulario(BuildContext context) async {
    final enviado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FormularioInteresse(repositorio: repositorio),
    );
    if (enviado == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Recebemos seu interesse! Assim que o espaço abrir, a gente entra '
            'em contato pelo canal que você deixou.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Sua Loja')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: cores.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.storefront, color: cores.onPrimaryContainer),
                      const SizedBox(width: 8),
                      Text(
                        'Este espaço é seu',
                        style: textos.titleLarge?.copyWith(color: cores.onPrimaryContainer),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Muitas mulheres que usam o app também vendem: roupa fitness, '
                    'produtos naturais, artesanato, doces, cosméticos, serviços. '
                    'A "Sua Loja" vai ser a vitrine dessas marcas — para todas as '
                    'outras usuárias verem.',
                    style: TextStyle(color: cores.onPrimaryContainer),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('O que você vai poder fazer aqui', style: textos.titleMedium),
          const SizedBox(height: 8),
          const _Item(
            icone: Icons.link,
            texto: 'Mostrar os links da sua loja: Instagram, TikTok, Mercado Livre, '
                'Shopee, seu site.',
          ),
          const _Item(
            icone: Icons.photo_library_outlined,
            texto: 'Fotos dos seus produtos.',
          ),
          const _Item(
            icone: Icons.notes,
            texto: 'Um texto contando a história e o diferencial da sua marca.',
          ),
          const _Item(
            icone: Icons.videocam_outlined,
            texto: 'Em breve: um vídeo curto (10 a 15 segundos) para você se '
                'apresentar e falar do que vende.',
          ),
          const SizedBox(height: 24),
          Text('O alcance', style: textos.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Sua loja aparece para todas as usuárias do app — mulheres que já '
            'decidiram investir na própria saúde e bem-estar, e que costumam '
            'apoiar quem faz parte da mesma jornada.',
            style: textos.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text('Quanto custa', style: textos.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Um valor simbólico por mês, pensado para ser acessível para quem '
            'está começando. As primeiras marcas entram com condição especial.',
            style: textos.bodyMedium,
          ),
          const SizedBox(height: 24),
          Card(
            color: cores.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estamos montando esse espaço agora',
                    style: textos.titleMedium?.copyWith(color: cores.onSecondaryContainer),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Deixe seu interesse e a gente te chama assim que a "Sua Loja" '
                    'abrir. Sem compromisso e sem cobrança agora — é só para '
                    'você garantir seu lugar entre as primeiras.',
                    style: TextStyle(color: cores.onSecondaryContainer),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      key: const Key('botao-quero-anunciar'),
                      onPressed: () => _abrirFormulario(context),
                      icon: const Icon(Icons.storefront),
                      label: const Text('Quero anunciar minha loja'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Os produtos e serviços anunciados na "Sua Loja" são de anunciantes '
            'independentes, cada um responsável pelo próprio anúncio, pelas '
            'vendas e pelo atendimento. O app apenas cede o espaço de '
            'divulgação e não participa das negociações.',
            style: textos.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(texto, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _FormularioInteresse extends StatefulWidget {
  const _FormularioInteresse({required this.repositorio});

  final SuaLojaRepository repositorio;

  @override
  State<_FormularioInteresse> createState() => _FormularioInteresseState();
}

class _FormularioInteresseState extends State<_FormularioInteresse> {
  final _nome = TextEditingController();
  final _contato = TextEditingController();
  final _oQueVende = TextEditingController();
  final _links = TextEditingController();
  bool _autorizaContato = false;
  bool _enviando = false;
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    _contato.dispose();
    _oQueVende.dispose();
    _links.dispose();
    super.dispose();
  }

  bool get _valido =>
      _nome.text.trim().isNotEmpty &&
      _contato.text.trim().isNotEmpty &&
      _oQueVende.text.trim().isNotEmpty &&
      _autorizaContato;

  Future<void> _enviar() async {
    if (!_valido || _enviando) return;
    setState(() {
      _enviando = true;
      _erro = null;
    });
    try {
      await widget.repositorio.enviarInteresse(
        nomeMarca: _nome.text,
        contato: _contato.text,
        oQueVende: _oQueVende.text,
        links: _links.text,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _enviando = false;
          _erro = 'Não deu para enviar agora. Confira sua conexão e tente de novo.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quero anunciar minha loja', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'A gente entra em contato quando o espaço abrir. Nada é cobrado agora.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('campo-nome-marca'),
              controller: _nome,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Seu nome ou o nome da marca'),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('campo-contato'),
              controller: _contato,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'WhatsApp ou e-mail para contato'),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('campo-o-que-vende'),
              controller: _oQueVende,
              onChanged: (_) => setState(() {}),
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'O que você vende?'),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('campo-links'),
              controller: _links,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Seus links (Instagram, TikTok, loja...) — opcional',
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              key: const Key('check-contato'),
              value: _autorizaContato,
              onChanged: (v) => setState(() => _autorizaContato = v ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Aceito ser contatada sobre o espaço "Sua Loja".'),
            ),
            if (_erro != null) ...[
              const SizedBox(height: 4),
              Text(_erro!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                key: const Key('botao-enviar-interesse'),
                onPressed: _valido && !_enviando ? _enviar : null,
                child: _enviando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enviar interesse'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
