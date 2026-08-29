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
      tooltip: 'Como tirar as fotos de progresso',
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
                  Text('Fotos de progresso', style: texto.titleLarge),
                  const SizedBox(height: 16),
                  Text(
                    'A balança sozinha engana — ela sobe quando você ganha músculo '
                    'e não mostra a mudança de forma do corpo. A foto mostra.',
                    style: texto.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  Text('Para a comparação valer:', style: texto.titleSmall),
                  const SizedBox(height: 8),
                  _Item(
                    titulo: 'Roupa justa ou biquíni',
                    corpo: 'Roupa larga esconde a evolução. De biquíni, top e '
                        'shorts curto, ou roupa de treino justa, dá pra ver de '
                        'verdade a mudança na cintura, glúteo e pernas.',
                  ),
                  _Item(
                    titulo: 'Mesmo ângulo sempre',
                    corpo: 'Marque cada foto como Frente, Lado ou Costas. O '
                        'antes/depois compara frente com frente, não frente com '
                        'costas. Livre é pra focar num ponto específico.',
                  ),
                  _Item(
                    titulo: 'Mesma luz e mesmo lugar',
                    corpo: 'De preferência de manhã, em jejum, no mesmo cômodo, '
                        'sem filtro. Luz de frente, não de cima.',
                  ),
                  _Item(
                    titulo: 'A cada 2 a 4 semanas',
                    corpo: 'Todo dia não adianta — a mudança não aparece de um dia '
                        'pro outro e você desanima à toa.',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Suas fotos ficam na sua conta e só você vê. Sincronizam entre '
                    'seus aparelhos.',
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
