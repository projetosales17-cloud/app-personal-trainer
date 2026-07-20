import 'package:flutter/material.dart';

import '../models/anamnese.dart';
import '../saude/hidratacao.dart';
import '../services/anamnese_repository.dart';

class HidratacaoView extends StatefulWidget {
  HidratacaoView({super.key, AnamneseRepository? repositorio})
    : repositorio = repositorio ?? AnamneseRepository();

  final AnamneseRepository repositorio;

  @override
  State<HidratacaoView> createState() => _HidratacaoViewState();
}

class _HidratacaoViewState extends State<HidratacaoView> {
  late final Future<Anamnese?> _anamneseFuture = widget.repositorio.carregar();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Anamnese?>(
      future: _anamneseFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final anamnese = snapshot.data;
        if (anamnese == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Complete a anamnese no onboarding para ver sua meta de hidratação.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final metaMl = calcularHidratacaoDiaria(anamnese.pesoAtualKg, anamnese.nivelAtividade);
        final metaLitros = (metaMl / 1000).toStringAsFixed(1);

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_drink,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text('$metaLitros L por dia', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Meta calculada a partir do seu peso e nível de atividade.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
