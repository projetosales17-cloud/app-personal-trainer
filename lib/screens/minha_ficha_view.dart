import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../models/anamnese.dart';
import '../models/checkin_treino.dart';
import '../models/exercicio.dart';
import '../models/ficha_treino.dart';
import '../services/anamnese_repository.dart';
import '../services/biblioteca_exercicios_repository.dart';
import '../services/checkin_treino_repository.dart';
import '../services/gamificacao_service.dart';
import '../services/gerador_ficha_treino.dart';
import '../services/motor_aderencia.dart';
import '../services/notificador_conquistas.dart';
import '../services/preferencias_repository.dart';
import 'exercicio_detalhe_screen.dart';

const _rotulosDiasSemana = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

class MinhaFichaView extends StatefulWidget {
  MinhaFichaView({
    super.key,
    AnamneseRepository? anamneseRepositorio,
    BibliotecaExerciciosRepository? bibliotecaRepositorio,
    PreferenciasRepository? preferenciasRepositorio,
    CheckinTreinoRepository? checkinRepositorio,
    MotorAderencia? motorAderencia,
    GamificacaoService? gamificacaoService,
    NotificadorConquistas? notificadorConquistas,
  }) : anamneseRepositorio = anamneseRepositorio ?? AnamneseRepository(),
       geradorFicha = GeradorFichaTreino(repositorio: bibliotecaRepositorio),
       preferenciasRepositorio = preferenciasRepositorio ?? PreferenciasRepository(),
       checkinRepositorio = checkinRepositorio ?? CheckinTreinoRepository(),
       motorAderencia = motorAderencia ?? MotorAderencia(),
       gamificacaoService = gamificacaoService ?? GamificacaoService(),
       notificadorConquistas =
           notificadorConquistas ??
           (kIsWeb ? const NotificadorConquistasNulo() : NotificadorConquistasLocal());

  final AnamneseRepository anamneseRepositorio;
  final GeradorFichaTreino geradorFicha;
  final PreferenciasRepository preferenciasRepositorio;
  final CheckinTreinoRepository checkinRepositorio;
  final MotorAderencia motorAderencia;
  final GamificacaoService gamificacaoService;
  final NotificadorConquistas notificadorConquistas;

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
  late Future<List<CheckinTreino>> _checkinsFuture = widget.checkinRepositorio.listar();

  Future<void> _salvarDiasDaSemana(List<int> diasDaSemana) async {
    await widget.preferenciasRepositorio.definirDiasDaSemanaEscolhidos(diasDaSemana);
    setState(() {
      _diasDaSemanaFuture = widget.preferenciasRepositorio.diasDaSemanaEscolhidos();
    });
  }

  Future<void> _alternarConcluido(DateTime data, int diaFicha, bool concluido) async {
    final diasDaSemana = await _diasDaSemanaFuture;
    final checkinsAntes = await widget.checkinRepositorio.listar();

    if (concluido) {
      await widget.checkinRepositorio.marcarConcluido(data, diaFicha);
    } else {
      await widget.checkinRepositorio.desmarcarConcluido(data, diaFicha);
    }

    final checkinsDepois = await widget.checkinRepositorio.listar();
    await _notificarSeBateuMarco(diasDaSemana, checkinsAntes, checkinsDepois);

    setState(() {
      _checkinsFuture = Future.value(checkinsDepois);
    });
  }

  /// Compara a gamificação antes/depois do check-in e dispara uma
  /// notificação local imediata (ver briefing do produto) quando um novo
  /// marco de streak é atingido ou a meta semanal passa a ser batida —
  /// sem geração de cupom, que depende de uma loja real ainda inexistente.
  Future<void> _notificarSeBateuMarco(
    List<int>? diasDaSemana,
    List<CheckinTreino> checkinsAntes,
    List<CheckinTreino> checkinsDepois,
  ) async {
    final antes = widget.gamificacaoService.calcular(
      diasDaSemanaEsperados: diasDaSemana,
      datasCheckin: [for (final c in checkinsAntes) c.data],
    );
    final depois = widget.gamificacaoService.calcular(
      diasDaSemanaEsperados: diasDaSemana,
      datasCheckin: [for (final c in checkinsDepois) c.data],
    );

    if (depois.streakDias > antes.streakDias &&
        GamificacaoService.marcosStreak.contains(depois.streakDias)) {
      await widget.notificadorConquistas.notificar(
        titulo: 'Sequência de ${depois.streakDias} dias!',
        corpo: 'Você bateu um novo marco de streak. Continue assim!',
      );
    } else if (!antes.metaSemanalBatida && depois.metaSemanalBatida) {
      await widget.notificadorConquistas.notificar(
        titulo: 'Meta semanal batida!',
        corpo: 'Você completou todos os treinos previstos dessa semana.',
      );
    }
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

        return FutureBuilder<List<int>?>(
          future: _diasDaSemanaFuture,
          builder: (context, diasSnapshot) {
            if (diasSnapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final diasDaSemana = diasSnapshot.data;

            return FutureBuilder<List<CheckinTreino>>(
              future: _checkinsFuture,
              builder: (context, checkinsSnapshot) {
                if (checkinsSnapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                final checkins = checkinsSnapshot.data ?? const [];
                final datasCheckin = [for (final c in checkins) c.data];
                final aderencia = widget.motorAderencia.avaliar(
                  diasDaSemanaEsperados: diasDaSemana,
                  datasCheckin: datasCheckin,
                );
                final gamificacao = widget.gamificacaoService.calcular(
                  diasDaSemanaEsperados: diasDaSemana,
                  datasCheckin: datasCheckin,
                );
                final ficha = widget.geradorFicha.gerar(
                  anamnese,
                  reduzirVolumeRetomada: aderencia.emAlerta,
                );

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Válida até ${_formatarData(ficha.validaAte)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    if (ficha.prescricao != null) ...[
                      _CartaoPrescricao(prescricao: ficha.prescricao!),
                      const SizedBox(height: 8),
                    ],
                    _CartaoGamificacao(resultado: gamificacao),
                    if (aderencia.emAlerta) ...[
                      const SizedBox(height: 8),
                      Card(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            aderencia.mensagem!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                    ],
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
                        checkins: checkins,
                        aoAlternarConcluido: _alternarConcluido,
                      ),
                  ],
                );
              },
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

class _CartaoPrescricao extends StatelessWidget {
  const _CartaoPrescricao({required this.prescricao});

  final PrescricaoTreino prescricao;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Como fazer este treino', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Text('${prescricao.series} · ${prescricao.repeticoes}'),
            Text('Descanso: ${prescricao.descanso}'),
            const SizedBox(height: 6),
            Text(prescricao.estilo, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _CartaoGamificacao extends StatelessWidget {
  const _CartaoGamificacao({required this.resultado});

  final ResultadoGamificacao resultado;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.local_fire_department_outlined),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Streak: ${resultado.streakDias} dia(s) · ${resultado.pontosTotais} pontos'
                '${resultado.metaSemanalBatida ? ' · Meta semanal batida!' : ''}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiaDeTreinoCard extends StatelessWidget {
  const _DiaDeTreinoCard({
    required this.dia,
    required this.datas,
    required this.checkins,
    required this.aoAlternarConcluido,
  });

  final DiaDeTreino dia;
  final List<DateTime> datas;
  final List<CheckinTreino> checkins;
  final Future<void> Function(DateTime data, int diaFicha, bool concluido) aoAlternarConcluido;

  bool _concluido(DateTime data) {
    final dataNormalizada = DateTime(data.year, data.month, data.day);
    return checkins.any(
      (c) => c.data == dataNormalizada && c.diaFicha == dia.dia,
    );
  }

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
              Text('Datas sugeridas:', style: Theme.of(context).textTheme.bodySmall),
              for (final data in datas)
                CheckboxListTile(
                  key: Key('checkin-dia-${dia.dia}-${data.toIso8601String().substring(0, 10)}'),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  title: Text(_formatarData(data)),
                  value: _concluido(data),
                  onChanged: (marcado) => aoAlternarConcluido(data, dia.dia, marcado ?? false),
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
