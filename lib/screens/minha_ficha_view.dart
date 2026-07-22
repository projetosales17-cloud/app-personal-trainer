import 'package:flutter/material.dart';

import '../models/anamnese.dart';
import '../models/exercicio.dart';
import '../models/ficha_treino.dart';
import '../services/anamnese_repository.dart';
import '../services/biblioteca_exercicios_repository.dart';
import '../services/gerador_ficha_treino.dart';
import '../services/preferencias_repository.dart';
import 'exercicio_detalhe_screen.dart';

const _rotulosDiasSemana = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

class MinhaFichaView extends StatefulWidget {
  MinhaFichaView({
    super.key,
    AnamneseRepository? anamneseRepositorio,
    BibliotecaExerciciosRepository? bibliotecaRepositorio,
    PreferenciasRepository? preferenciasRepositorio,
  }) : anamneseRepositorio = anamneseRepositorio ?? AnamneseRepository(),
       geradorFicha = GeradorFichaTreino(repositorio: bibliotecaRepositorio),
       preferenciasRepositorio = preferenciasRepositorio ?? PreferenciasRepository();

  final AnamneseRepository anamneseRepositorio;
  final GeradorFichaTreino geradorFicha;
  final PreferenciasRepository preferenciasRepositorio;

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
  late Future<List<int>?> _diasDaSemanaFuture =
      widget.preferenciasRepositorio.diasDaSemanaEscolhidos();

  Future<void> _salvarDiasDaSemana(List<int> diasDaSemana) async {
    await widget.preferenciasRepositorio.definirDiasDaSemanaEscolhidos(diasDaSemana);
    setState(() {
      _diasDaSemanaFuture = widget.preferenciasRepositorio.diasDaSemanaEscolhidos();
    });
  }

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

        return FutureBuilder<List<int>?>(
          future: _diasDaSemanaFuture,
          builder: (context, diasSnapshot) {
            if (diasSnapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final diasDaSemana = diasSnapshot.data;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Válida até ${_formatarData(ficha.validaAte)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _SeletorDiasDaSemana(
                  quantidadeDias: ficha.dias.length,
                  diasIniciais: diasDaSemana,
                  aoSalvar: _salvarDiasDaSemana,
                ),
                const SizedBox(height: 16),
                for (final dia in ficha.dias)
                  _DiaDeTreinoCard(
                    dia: dia,
                    datas: ficha.datasPara(dia, diasDaSemana: diasDaSemana),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Deixa a usuária escolher manualmente os dias da semana do treino, em vez
/// de depender só da distribuição automática aproximada (ver briefing do
/// produto). Exige selecionar exatamente [quantidadeDias] dias antes de
/// habilitar salvar.
class _SeletorDiasDaSemana extends StatefulWidget {
  const _SeletorDiasDaSemana({
    required this.quantidadeDias,
    required this.diasIniciais,
    required this.aoSalvar,
  });

  final int quantidadeDias;
  final List<int>? diasIniciais;
  final ValueChanged<List<int>> aoSalvar;

  @override
  State<_SeletorDiasDaSemana> createState() => _SeletorDiasDaSemanaState();
}

class _SeletorDiasDaSemanaState extends State<_SeletorDiasDaSemana> {
  final Set<int> _selecionados = {};

  @override
  void initState() {
    super.initState();
    _selecionados.addAll(widget.diasIniciais ?? const []);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Meus dias de treino', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Escolha exatamente ${widget.quantidadeDias} dia(s) da semana '
              '(${_selecionados.length} de ${widget.quantidadeDias} selecionado(s)).',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (var diaSemana = 1; diaSemana <= 7; diaSemana++)
                  FilterChip(
                    key: Key('dia-semana-$diaSemana'),
                    label: Text(_rotulosDiasSemana[diaSemana - 1]),
                    selected: _selecionados.contains(diaSemana),
                    onSelected: (selecionado) {
                      setState(() {
                        if (selecionado) {
                          _selecionados.add(diaSemana);
                        } else {
                          _selecionados.remove(diaSemana);
                        }
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                key: const Key('botao-salvar-dias-treino'),
                onPressed: _selecionados.length == widget.quantidadeDias
                    ? () => widget.aoSalvar(_selecionados.toList()..sort())
                    : null,
                child: const Text('Salvar dias'),
              ),
            ),
          ],
        ),
      ),
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
            for (final atividade in dia.atividadesCardio)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.directions_run),
                title: Text(atividade.nome),
                subtitle: Text('${atividade.duracaoMinutosSugerida} min sugeridos'),
              ),
          ],
        ),
      ),
    );
  }
}
