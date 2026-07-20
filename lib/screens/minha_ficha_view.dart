import 'package:flutter/material.dart';

import '../models/anamnese.dart';
import '../models/exercicio.dart';
import '../models/ficha_treino.dart';
import '../services/anamnese_repository.dart';
import '../services/biblioteca_exercicios_repository.dart';
import '../services/gerador_ficha_treino.dart';
import 'exercicio_detalhe_screen.dart';

class MinhaFichaView extends StatefulWidget {
  MinhaFichaView({
    super.key,
    AnamneseRepository? anamneseRepositorio,
    BibliotecaExerciciosRepository? bibliotecaRepositorio,
  }) : anamneseRepositorio = anamneseRepositorio ?? AnamneseRepository(),
       geradorFicha = GeradorFichaTreino(repositorio: bibliotecaRepositorio);

  final AnamneseRepository anamneseRepositorio;
  final GeradorFichaTreino geradorFicha;

  @override
  State<MinhaFichaView> createState() => _MinhaFichaViewState();
}

String _formatarData(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year}';
}

class _MinhaFichaViewState extends State<MinhaFichaView> {
  late final Future<Anamnese?> _anamneseFuture = widget.anamneseRepositorio.carregar();

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
                'Complete a anamnese no onboarding para gerar sua ficha de treino.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final ficha = widget.geradorFicha.gerar(anamnese);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Válida até ${_formatarData(ficha.validaAte)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            for (final dia in ficha.dias)
              _DiaDeTreinoCard(dia: dia, datas: ficha.datasPara(dia)),
          ],
        );
      },
    );
  }
}

class _DiaDeTreinoCard extends StatelessWidget {
  const _DiaDeTreinoCard({required this.dia, required this.datas});

  final DiaDeTreino dia;
  final List<DateTime> datas;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dia ${dia.dia}', style: Theme.of(context).textTheme.titleMedium),
            if (datas.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Datas sugeridas: ${datas.map(_formatarData).join(', ')}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final grupo in dia.gruposMusculares)
                  Chip(label: Text(grupo.label), visualDensity: VisualDensity.compact),
              ],
            ),
            const Divider(height: 24),
            for (final exercicio in dia.exercicios)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(exercicio.nome),
                subtitle: Text(exercicio.grupoMuscularPrincipal.label),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ExercicioDetalheScreen(exercicio: exercicio),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
