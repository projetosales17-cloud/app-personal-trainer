import 'package:flutter/material.dart';

import '../services/sua_loja_repository.dart';

/// "Tu Tienda" — espaço em construção onde, em breve, as usuárias que
/// também vendem vão poder divulgar a própria marca para todas as outras.
/// Por enquanto a tela é só um teaser + lista de espera: mede a demanda
/// antes de construir cobrança, moderação e vitrine de verdade. Nada é
/// publicado e nada é cobrado aqui.
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
            '¡Recibimos tu interés! En cuanto el espacio abra, te contactamos '
            'por el canal que dejaste.',
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
      appBar: AppBar(title: const Text('Tu Tienda')),
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
                        'Este espacio es tuyo',
                        style: textos.titleLarge?.copyWith(color: cores.onPrimaryContainer),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Muchas mujeres que usan la app también venden: ropa fitness, '
                    'productos naturales, artesanías, postres, cosméticos, '
                    'servicios. "Tu Tienda" va a ser el escaparate de esas marcas '
                    '— para que todas las demás usuarias las vean.',
                    style: TextStyle(color: cores.onPrimaryContainer),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Lo que vas a poder hacer aquí', style: textos.titleMedium),
          const SizedBox(height: 8),
          const _Item(
            icone: Icons.link,
            texto: 'Mostrar los enlaces de tu tienda: Instagram, TikTok, '
                'Mercado Libre, tu sitio web.',
          ),
          const _Item(
            icone: Icons.photo_library_outlined,
            texto: 'Fotos de tus productos.',
          ),
          const _Item(
            icone: Icons.notes,
            texto: 'Un texto contando la historia y el diferencial de tu marca.',
          ),
          const _Item(
            icone: Icons.videocam_outlined,
            texto: 'Pronto: un video corto (10 a 15 segundos) para presentarte y '
                'hablar de lo que vendes.',
          ),
          const SizedBox(height: 24),
          Text('El alcance', style: textos.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Tu tienda aparece para todas las usuarias de la app — mujeres que ya '
            'decidieron invertir en su propia salud y bienestar, y que suelen '
            'apoyar a quien es parte del mismo camino.',
            style: textos.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text('Cuánto cuesta', style: textos.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Un valor simbólico al mes, pensado para que sea accesible para quien '
            'está empezando. Las primeras marcas entran con condición especial.',
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
                    'Estamos armando este espacio ahora',
                    style: textos.titleMedium?.copyWith(color: cores.onSecondaryContainer),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Deja tu interés y te avisamos en cuanto "Tu Tienda" abra. '
                    'Sin compromiso y sin cobro ahora — es solo para que asegures '
                    'tu lugar entre las primeras.',
                    style: TextStyle(color: cores.onSecondaryContainer),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      key: const Key('botao-quero-anunciar'),
                      onPressed: () => _abrirFormulario(context),
                      icon: const Icon(Icons.storefront),
                      label: const Text('Quiero anunciar mi tienda'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Los productos y servicios anunciados en "Tu Tienda" son de '
            'anunciantes independientes, cada uno responsable de su propio '
            'anuncio, de las ventas y de la atención. La app solo cede el '
            'espacio de difusión y no participa en las negociaciones.',
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
          _erro = 'No se pudo enviar ahora. Revisa tu conexión e inténtalo de nuevo.';
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
            Text('Quiero anunciar mi tienda', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Te contactamos cuando el espacio abra. No se cobra nada ahora.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('campo-nome-marca'),
              controller: _nome,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Tu nombre o el nombre de la marca'),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('campo-contato'),
              controller: _contato,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'WhatsApp o correo para contacto'),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('campo-o-que-vende'),
              controller: _oQueVende,
              onChanged: (_) => setState(() {}),
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: '¿Qué vendes?'),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('campo-links'),
              controller: _links,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Tus enlaces (Instagram, TikTok, tienda...) — opcional',
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              key: const Key('check-contato'),
              value: _autorizaContato,
              onChanged: (v) => setState(() => _autorizaContato = v ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Acepto que me contacten sobre el espacio "Tu Tienda".'),
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
                    : const Text('Enviar interés'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
