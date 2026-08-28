import 'package:flutter/material.dart';

/// Ícono de "?" al lado de "Fechas sugeridas" en la rutina. Al tocarlo,
/// abre una hoja explicando qué son las fechas, que marcar = "entrené",
/// y por qué la marcación importa (mucha gente no entiende la función y
/// deja de marcar).
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
      tooltip: 'Cómo marcar tus entrenamientos',
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
                  Text('Cómo marcar tus entrenamientos', style: texto.titleLarge),
                  const SizedBox(height: 16),
                  Text(
                    'Día 1, Día 2 y Día 3 son los días fijos que elegiste para '
                    'entrenar en la semana.',
                    style: texto.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Las fechas debajo de cada día son las próximas veces que '
                    'cae ese día (los próximos lunes, miércoles, viernes…), '
                    'hasta que venza tu rutina — dura 30 días.',
                    style: texto.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Marca la casilla cada vez que entrenes ese día. Es tu hoja '
                    'de asistencia.',
                    style: texto.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text('Por qué marcar importa:', style: texto.titleSmall),
                  const SizedBox(height: 8),
                  _Item(
                    titulo: 'Constancia',
                    corpo: 'Si faltas, la app arma una rutina más ligera para '
                        'ayudarte a volver sin desanimarte.',
                  ),
                  _Item(
                    titulo: 'Motivación',
                    corpo: 'La app cuenta tu racha de días entrenados y te avisa '
                        'cuando alcanzas una meta.',
                  ),
                  _Item(
                    titulo: 'Evolución',
                    corpo: 'Después de algunas semanas, la app usa tus marcas '
                        'para pedirte un check-in y darte una rutina más exigente.',
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
