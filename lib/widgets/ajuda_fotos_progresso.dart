import 'package:flutter/material.dart';

/// Ícone de "?" no topo da aba Fotos. Ao tocar, abre uma folha explicando
/// como tirar as fotos de progresso pra comparação valer alguma coisa
/// (mesmo ângulo, mesma luz, roupa justa/biquíni, a cada 2–4 semanas).
class BotaoAjudaFotosProgresso extends StatelessWidget {
  const BotaoAjudaFotosProgresso({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('botao-ajuda-fotos-progresso'),
      icon: const Icon(Icons.help_outline, size: 20),
      visualDensity: VisualDensity.compact,
      tooltip: 'Cómo tomar las fotos de progreso',
      onPressed: () => _mostrar(context),
    );
  }

  void _mostrar(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final texto = Theme.of(context).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Fotos de progreso', style: texto.titleLarge),
                  const SizedBox(height: 16),
                  Text(
                    'La balanza sola engaña — sube cuando ganas músculo y no '
                    'muestra el cambio de forma del cuerpo. La foto sí.',
                    style: texto.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  Text('Para que la comparación sirva:', style: texto.titleSmall),
                  const SizedBox(height: 8),
                  _Item(
                    titulo: 'Ropa ajustada o bikini',
                    corpo: 'La ropa holgada esconde la evolución. En bikini, top '
                        'y short corto, o ropa de entrenamiento ajustada, se ve '
                        'de verdad el cambio en la cintura, los glúteos y las piernas.',
                  ),
                  _Item(
                    titulo: 'Siempre el mismo ángulo',
                    corpo: 'Marca cada foto como Frente, Espalda, Lado izq. o '
                        'Lado der. El antes/después compara cada ángulo consigo '
                        'mismo. Libre es para enfocar un punto específico.',
                  ),
                  _Item(
                    titulo: 'Misma luz y mismo lugar',
                    corpo: 'De preferencia por la mañana, en ayunas, en la misma '
                        'habitación, sin filtro. Luz de frente, no de arriba.',
                  ),
                  _Item(
                    titulo: 'Cada 2 a 4 semanas',
                    corpo: 'Todos los días no sirve — el cambio no aparece de un '
                        'día para otro y te desanimas en vano.',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tus fotos quedan en tu cuenta y solo tú las ves. Se '
                    'sincronizan entre tus dispositivos.',
                    style: texto.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.titulo, required this.corpo});

  final String titulo;
  final String corpo;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: texto.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(corpo, style: texto.bodyMedium),
        ],
      ),
    );
  }
}
