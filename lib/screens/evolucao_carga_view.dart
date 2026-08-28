import 'package:flutter/material.dart';

import '../models/registro_carga.dart';
import '../saude/progressao_carga.dart';
import '../services/biblioteca_exercicios_repository.dart';
import '../services/treino_repository.dart';
import '../widgets/grafico_linha_simples.dart';

/// Aba de Progresso que mostra a evolução de carga por exercício — o dado
/// que a usuária já registra na tela de cada exercício, mas que até agora
/// ficava só numa lista. Aqui vira gráfico + resumo ("de X para Y kg em N
/// semanas"), pra dar a sensação de progresso que peso/medidas sozinhos
/// não dão.
class EvolucaoCargaView extends StatefulWidget {
  EvolucaoCargaView({
    super.key,
    TreinoRepository? treinoRepositorio,
    BibliotecaExerciciosRepository? bibliotecaRepositorio,
  }) : treinoRepositorio = treinoRepositorio ?? TreinoRepository(),
       bibliotecaRepositorio = bibliotecaRepositorio ?? BibliotecaExerciciosRepository();

  final TreinoRepository treinoRepositorio;
  final BibliotecaExerciciosRepository bibliotecaRepositorio;

  @override
  State<EvolucaoCargaView> createState() => _EvolucaoCargaViewState();
}

class _EvolucaoCargaViewState extends State<EvolucaoCargaView> {
  late final Future<List<RegistroCarga>> _cargasFuture =
      widget.treinoRepositorio.listarCargas();

  String _nomeExercicio(String id) =>
      widget.bibliotecaRepositorio.porId(id)?.nome ?? id;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RegistroCarga>>(
      future: _cargasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final evolucoes = resumirTodasAsEvolucoes(snapshot.data ?? const []);
        if (evolucoes.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Registre a carga dos seus exercícios (na aba Treino, abrindo '
                'cada exercício) por pelo menos duas sessões para ver a '
                'evolução aqui.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final progrediram = evolucoes.where((e) => e.progrediu).length;

        return ListView(
          key: const Key('lista-evolucao-carga'),
          padding: const EdgeInsets.all(16),
          children: [
            if (progrediram > 0) ...[
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Você aumentou a carga em $progrediram exercício(s). '
                    'Isso é força que aparece no dia a dia, não só na balança.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            for (final evolucao in evolucoes)
              _CartaoEvolucao(
                titulo: _nomeExercicio(evolucao.exercicioId),
                evolucao: evolucao,
              ),
          ],
        );
      },
    );
  }
}

class _CartaoEvolucao extends StatelessWidget {
  const _CartaoEvolucao({required this.titulo, required this.evolucao});

  final String titulo;
  final EvolucaoCarga evolucao;

  String _kg(double v) =>
      '${v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1)} kg';

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            GraficoLinhaSimples(valores: evolucao.pesos, altura: 90),
            const SizedBox(height: 8),
            Text(
              evolucao.progrediu
                  ? 'De ${_kg(evolucao.pesoInicial)} para ${_kg(evolucao.pesoAtual)} '
                        'em ${evolucao.semanas} semana(s)'
                        '${evolucao.ganhoPercentual > 0 ? ' · +${evolucao.ganhoPercentual}%' : ''}.'
                  : 'Carga estável em ${_kg(evolucao.pesoAtual)} ao longo de '
                        '${evolucao.totalRegistros} registro(s).',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
