import 'package:flutter/material.dart';

/// Ícone de "?" ao lado de "Datas sugeridas" na ficha de treino. Ao tocar,
/// abre uma folha explicando o que são as datas, que marcar = "eu
/// treinei", e por que a marcação importa (muita gente não entende a
/// função e deixa de marcar).
class BotaoAjudaMarcacaoTreino extends StatelessWidget {
  const BotaoAjudaMarcacaoTreino({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('botao-ajuda-marcacao-treino'),
      icon: const Icon(Icons.help_outline, size: 18),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      tooltip: 'Como marcar seus treinos',
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
                  Text('Como marcar seus treinos', style: texto.titleLarge),
                  const SizedBox(height: 16),
                  Text(
                    'Dia 1, Dia 2 e Dia 3 são os dias fixos que você escolheu '
                    'treinar na semana.',
                    style: texto.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'As datas abaixo de cada dia são as próximas ocorrências '
                    'desse dia (as próximas segundas, quartas, sextas…), até '
                    'sua ficha vencer — ela vale 30 dias.',
                    style: texto.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Marque a caixinha toda vez que você treinar naquele dia. '
                    'É a sua folha de presença.',
                    style: texto.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text('Por que marcar importa:', style: texto.titleSmall),
                  const SizedBox(height: 8),
                  _Item(
                    titulo: 'Consistência',
                    corpo: 'Se você faltar, o app monta uma ficha mais leve pra '
                        'te ajudar a voltar sem desanimar.',
                  ),
                  _Item(
                    titulo: 'Motivação',
                    corpo: 'O app conta sua sequência de dias treinados e te '
                        'avisa quando você bate uma meta.',
                  ),
                  _Item(
                    titulo: 'Evolução',
                    corpo: 'Depois de algumas semanas, o app usa suas marcações '
                        'pra pedir um check-in e liberar uma ficha mais puxada.',
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
      padding: const EdgeInsets.only(bottom: 10),
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
