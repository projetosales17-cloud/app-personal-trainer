import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../models/anamnese.dart';
import '../models/checkin_treino.dart';
import '../models/estrategia_bloco.dart';
import '../models/exercicio.dart';
import '../models/ficha_treino.dart';
import '../models/programa_treino.dart';
import '../services/anamnese_repository.dart';
import '../services/biblioteca_exercicios_repository.dart';
import '../services/checkin_treino_repository.dart';
import '../services/gamificacao_service.dart';
import '../services/gerador_ficha_treino.dart';
import '../services/motor_aderencia.dart';
import '../services/notificador_conquistas.dart';
import '../services/preferencias_repository.dart';
import '../services/programa_treino_repository.dart';
import '../services/progresso_repository.dart';
import '../services/trocas_exercicio_repository.dart';
import '../widgets/ajuda_marcacao_treino.dart';
import 'checkin_progresso_screen.dart';
import 'exercicio_detalhe_screen.dart';

const _rotulosDiasSemana = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

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
    ProgramaTreinoRepository? programaRepositorio,
    ProgressoRepository? progressoRepositorio,
    TrocasExercicioRepository? trocasRepositorio,
  }) : anamneseRepositorio = anamneseRepositorio ?? AnamneseRepository(),
       bibliotecaRepositorio = bibliotecaRepositorio ?? BibliotecaExerciciosRepository(),
       geradorFicha = GeradorFichaTreino(
         repositorio: bibliotecaRepositorio ?? BibliotecaExerciciosRepository(),
       ),
       preferenciasRepositorio = preferenciasRepositorio ?? PreferenciasRepository(),
       checkinRepositorio = checkinRepositorio ?? CheckinTreinoRepository(),
       motorAderencia = motorAderencia ?? MotorAderencia(),
       gamificacaoService = gamificacaoService ?? GamificacaoService(),
       programaRepositorio = programaRepositorio ?? ProgramaTreinoRepository(),
       progressoRepositorio = progressoRepositorio ?? ProgressoRepository(),
       trocasRepositorio = trocasRepositorio ?? TrocasExercicioRepository(),
       notificadorConquistas =
           notificadorConquistas ??
           (kIsWeb ? const NotificadorConquistasNulo() : NotificadorConquistasLocal());

  final AnamneseRepository anamneseRepositorio;
  final BibliotecaExerciciosRepository bibliotecaRepositorio;
  final GeradorFichaTreino geradorFicha;
  final TrocasExercicioRepository trocasRepositorio;
  final PreferenciasRepository preferenciasRepositorio;
  final CheckinTreinoRepository checkinRepositorio;
  final MotorAderencia motorAderencia;
  final GamificacaoService gamificacaoService;
  final NotificadorConquistas notificadorConquistas;
  final ProgramaTreinoRepository programaRepositorio;
  final ProgressoRepository progressoRepositorio;

  @override
  State<MinhaFichaView> createState() => _MinhaFichaViewState();
}

String _formatarData(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year}';
}

class _MinhaFichaViewState extends State<MinhaFichaView> {
  late Future<Anamnese?> _anamneseFuture = widget.anamneseRepositorio.carregar();
  late Future<List<int>?> _diasDaSemanaFuture =
      widget.preferenciasRepositorio.diasDaSemanaEscolhidos();
  late Future<List<CheckinTreino>> _checkinsFuture = widget.checkinRepositorio.listar();
  late Future<ProgramaTreino> _programaFuture =
      widget.programaRepositorio.iniciarSeNecessario();
  late Future<Map<String, String>> _trocasFuture = widget.trocasRepositorio.carregar();
  late Future<Set<String>> _removidosFuture = widget.trocasRepositorio.removidos();

  @override
  void initState() {
    super.initState();
    AnamneseRepository.revisao.addListener(_recarregarAnamnese);
  }

  @override
  void dispose() {
    AnamneseRepository.revisao.removeListener(_recarregarAnamnese);
    super.dispose();
  }

  /// A usuária editou a anamnese pelo Perfil — regera a ficha na hora.
  void _recarregarAnamnese() {
    if (!mounted) return;
    setState(() {
      _anamneseFuture = widget.anamneseRepositorio.carregar();
    });
  }

  /// Abre a folha de alternativas do mesmo grupo muscular para [original]
  /// e persiste a troca escolhida. [jaNaFicha] são os ids de exercícios
  /// que já estão no dia, para não oferecer repetição. Quando o treino é
  /// em casa, os exercícios sem equipamento de academia aparecem primeiro
  /// — mas os de academia ainda são oferecidos (com o equipamento à
  /// mostra), pra nunca deixar a usuária sem alternativa.
  Future<void> _trocarExercicio(
    Exercicio original,
    Set<String> jaNaFicha, {
    required bool priorizarEmCasa,
  }) async {
    final alternativas = widget.bibliotecaRepositorio
        .filtrar(grupoMuscular: original.grupoMuscularPrincipal)
        .where((e) => e.id != original.id && !jaNaFicha.contains(e.id))
        .toList();

    int prioridadeCasa(Exercicio e) =>
        (priorizarEmCasa && !equipamentosCasa.contains(e.equipamento)) ? 1 : 0;
    // Em casa primeiro (quando for o caso), depois os mais leves.
    alternativas.sort((a, b) {
      final porCasa = prioridadeCasa(a).compareTo(prioridadeCasa(b));
      return porCasa != 0 ? porCasa : a.nivel.index.compareTo(b.nivel.index);
    });

    if (!mounted) return;
    if (alternativas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sin otra opción para ese grupo ahora.')),
      );
      return;
    }

    final escolhido = await showModalBottomSheet<Object>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Cambiar "${original.nome}" por',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListTile(
              key: Key('opcao-remover-${original.id}'),
              leading: const Icon(Icons.not_interested),
              title: const Text('No hacer este ejercicio'),
              subtitle: const Text('Sale de tu rutina hasta el próximo check-in'),
              onTap: () => Navigator.of(context).pop('__remover__'),
            ),
            const Divider(),
            for (final alternativa in alternativas)
              ListTile(
                key: Key('opcao-troca-${alternativa.id}'),
                title: Text(alternativa.nome),
                subtitle: Text('${alternativa.nivel.label} · ${alternativa.equipamento.label}'),
                onTap: () => Navigator.of(context).pop(alternativa),
              ),
          ],
        ),
      ),
    );

    if (escolhido == '__remover__') {
      await _removerExercicio(original.id);
      return;
    }
    if (escolhido is! Exercicio) return;
    await widget.trocasRepositorio.trocar(original.id, escolhido.id);
    if (!mounted) return;
    setState(() {
      _trocasFuture = widget.trocasRepositorio.carregar();
    });
  }

  Future<void> _desfazerTroca(String exercicioOriginalId) async {
    await widget.trocasRepositorio.desfazer(exercicioOriginalId);
    if (!mounted) return;
    setState(() {
      _trocasFuture = widget.trocasRepositorio.carregar();
    });
  }

  Future<void> _removerExercicio(String exercicioId) async {
    await widget.trocasRepositorio.remover(exercicioId);
    if (!mounted) return;
    setState(() {
      _removidosFuture = widget.trocasRepositorio.removidos();
    });
  }

  Future<void> _restaurarExercicio(String exercicioId) async {
    await widget.trocasRepositorio.restaurar(exercicioId);
    if (!mounted) return;
    setState(() {
      _removidosFuture = widget.trocasRepositorio.removidos();
    });
  }

  Future<void> _abrirCheckin(ProgramaTreino programa) async {
    final ultimoPeso = await widget.progressoRepositorio.ultimoPeso();
    if (!mounted) return;
    final fez = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CheckinProgressoScreen(
          blocoConcluido: programa.blocoAtual,
          programaRepositorio: widget.programaRepositorio,
          pesoSugerido: ultimoPeso?.pesoKg,
        ),
      ),
    );
    if (fez == true && mounted) {
      // Ficha nova entra em cena: as trocas manuais do bloco anterior
      // deixam de fazer sentido.
      await widget.trocasRepositorio.limparTudo();
      if (!mounted) return;
      setState(() {
        _programaFuture = widget.programaRepositorio.iniciarSeNecessario();
        _trocasFuture = widget.trocasRepositorio.carregar();
        _removidosFuture = widget.trocasRepositorio.removidos();
      });
    }
  }

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
        titulo: '¡Racha de ${depois.streakDias} días!',
        corpo: 'Alcanzaste un nuevo hito de racha. ¡Sigue así!',
      );
    } else if (!antes.metaSemanalBatida && depois.metaSemanalBatida) {
      await widget.notificadorConquistas.notificar(
        titulo: '¡Meta semanal cumplida!',
        corpo: 'Completaste todos los entrenamientos previstos para esta semana.',
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
                'Completa la anamnesis en el registro inicial para generar tu rutina de entrenamiento.',
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

            return FutureBuilder<ProgramaTreino>(
              future: _programaFuture,
              builder: (context, programaSnapshot) {
                if (!programaSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final programa = programaSnapshot.data!;
                final estrategia = calcularEstrategiaBloco(
                  bloco: programa.blocoAtual,
                  nivelLiberado: programa.nivelLiberado,
                  ultimoCheckin: programa.ultimoCheckin,
                );

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
                  estrategiaBloco: estrategia,
                );
                final precisaCheckin = programa.precisaCheckin();

                return FutureBuilder<Map<String, String>>(
                  future: _trocasFuture,
                  builder: (context, trocasSnapshot) {
                    final trocas = trocasSnapshot.data ?? const <String, String>{};

                    Exercicio comTroca(Exercicio original) {
                      final substitutoId = trocas[original.id];
                      if (substitutoId == null) return original;
                      return widget.bibliotecaRepositorio.porId(substitutoId) ?? original;
                    }

                    final treinoEmCasa = anamnese.localTreino == LocalTreino.casa;
                    final gruposEvitados = GeradorFichaTreino.gruposEvitadosDe(anamnese);
                    final semMusculacao = ficha.dias.every((d) => d.exercicios.isEmpty);

                    return FutureBuilder<Set<String>>(
                      future: _removidosFuture,
                      builder: (context, removidosSnapshot) {
                    final removidos = removidosSnapshot.data ?? const <String>{};

                    return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (precisaCheckin) ...[
                      Card(
                        key: const Key('cartao-checkin-disponivel'),
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Terminaste el bloque ${programa.blocoAtual}',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Haz tu check-in de progreso para generar la próxima rutina.',
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: FilledButton(
                                  key: const Key('botao-abrir-checkin'),
                                  onPressed: () => _abrirCheckin(programa),
                                  child: const Text('Hacer check-in'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      'Válida hasta ${_formatarData(ficha.validaAte)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (gruposEvitados.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Rutina sin: ${gruposEvitados.map((g) => g.label).join(', ')} '
                        '— ajusta en Perfil › Editar mis datos.',
                        key: const Key('aviso-grupos-evitados'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (semMusculacao &&
                        anamnese.preferenciaTreino != PreferenciaTreino.soCardio) ...[
                      const SizedBox(height: 8),
                      Card(
                        color: Theme.of(context).colorScheme.errorContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            'Marcaste demasiados grupos para evitar: tu rutina quedó '
                            'solo con cardio. Suelta algún grupo en Perfil › Editar mis '
                            'datos para volver a musculación.',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (ficha.prescricao != null) ...[
                      _CartaoPrescricao(
                        prescricao: ficha.prescricao!,
                        estrategia: estrategia,
                        semana: programa.semanaAtual(),
                        semanasParaCheckin:
                            precisaCheckin ? 0 : programa.semanasParaProximoCheckin(),
                      ),
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
                        exerciciosExibidos: [
                          for (final ex in dia.exercicios) comTroca(ex),
                        ],
                        exerciciosOriginais: dia.exercicios,
                        idsTrocados: {
                          for (final ex in dia.exercicios)
                            if (trocas.containsKey(ex.id)) ex.id,
                        },
                        idsRemovidos: removidos,
                        aoTrocar: (original) => _trocarExercicio(
                          original,
                          {for (final ex in dia.exercicios) comTroca(ex).id},
                          priorizarEmCasa: treinoEmCasa,
                        ),
                        aoDesfazerTroca: _desfazerTroca,
                        aoRestaurar: _restaurarExercicio,
                      ),
                  ],
                );
                      },
                    );
                  },
                );
              },
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
            Text('Mis días de entrenamiento', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Elige exactamente ${widget.quantidadeDias} día(s) de la semana '
              '(${_selecionados.length} de ${widget.quantidadeDias} seleccionado(s)).',
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
                child: const Text('Guardar días'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartaoPrescricao extends StatelessWidget {
  const _CartaoPrescricao({
    required this.prescricao,
    this.estrategia,
    this.semana,
    this.semanasParaCheckin,
  });

  final PrescricaoTreino prescricao;
  final EstrategiaBloco? estrategia;
  final int? semana;
  final int? semanasParaCheckin;

  @override
  Widget build(BuildContext context) {
    final estrategia = this.estrategia;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cómo hacer este entrenamiento', style: Theme.of(context).textTheme.titleSmall),
            if (estrategia != null) ...[
              const SizedBox(height: 4),
              Text(
                semana != null
                    ? 'Semana $semana · ${estrategia.faseNome}'
                    : estrategia.faseNome,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 6),
            Text('${prescricao.series} · ${prescricao.repeticoes}'),
            Text('Descanso: ${prescricao.descanso}'),
            const SizedBox(height: 6),
            Text(prescricao.estilo, style: Theme.of(context).textTheme.bodySmall),
            if (estrategia != null && estrategia.mensagem != estrategia.faseDescricao) ...[
              const SizedBox(height: 6),
              Text(estrategia.mensagem, style: Theme.of(context).textTheme.bodySmall),
            ],
            if (semanasParaCheckin != null && semanasParaCheckin! > 0) ...[
              const SizedBox(height: 6),
              Text(
                'Próximo check-in de progreso en $semanasParaCheckin semana(s).',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
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
                'Racha: ${resultado.streakDias} día(s) · ${resultado.pontosTotais} puntos'
                '${resultado.metaSemanalBatida ? ' · ¡Meta semanal cumplida!' : ''}',
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
    required this.exerciciosExibidos,
    required this.exerciciosOriginais,
    required this.idsTrocados,
    required this.idsRemovidos,
    required this.aoTrocar,
    required this.aoDesfazerTroca,
    required this.aoRestaurar,
  });

  final DiaDeTreino dia;
  final List<DateTime> datas;
  final List<CheckinTreino> checkins;
  final Future<void> Function(DateTime data, int diaFicha, bool concluido) aoAlternarConcluido;

  /// Exercícios já com as trocas manuais aplicadas — é o que a usuária vê.
  final List<Exercicio> exerciciosExibidos;

  /// Exercícios como o gerador montou, na mesma ordem de [exerciciosExibidos].
  final List<Exercicio> exerciciosOriginais;

  /// Ids (dos originais) que estão trocados agora.
  final Set<String> idsTrocados;

  /// Ids (dos originais) que a usuária tirou do treino ("não fazer").
  final Set<String> idsRemovidos;

  final void Function(Exercicio original) aoTrocar;
  final void Function(String exercicioOriginalId) aoDesfazerTroca;
  final void Function(String exercicioId) aoRestaurar;

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
            Text('Día ${dia.dia}', style: Theme.of(context).textTheme.titleMedium),
            if (datas.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('Fechas sugeridas:', style: Theme.of(context).textTheme.bodySmall),
                  const BotaoAjudaMarcacaoTreino(),
                ],
              ),
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
            for (var i = 0; i < exerciciosExibidos.length; i++)
              if (idsRemovidos.contains(exerciciosOriginais[i].id))
                ListTile(
                  key: Key('removido-${exerciciosOriginais[i].id}'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: const Icon(Icons.not_interested, size: 20),
                  title: Text(
                    exerciciosOriginais[i].nome,
                    style: const TextStyle(decoration: TextDecoration.lineThrough),
                  ),
                  subtitle: const Text('Fuera de la rutina'),
                  trailing: TextButton(
                    key: Key('restaurar-${exerciciosOriginais[i].id}'),
                    onPressed: () => aoRestaurar(exerciciosOriginais[i].id),
                    child: const Text('Restaurar'),
                  ),
                )
              else
                _ExercicioTile(
                  exibido: exerciciosExibidos[i],
                  original: exerciciosOriginais[i],
                  trocado: idsTrocados.contains(exerciciosOriginais[i].id),
                  aoTrocar: aoTrocar,
                  aoDesfazerTroca: aoDesfazerTroca,
                ),
            if (exerciciosExibidos.isNotEmpty &&
                exerciciosOriginais.every((e) => idsRemovidos.contains(e.id)) &&
                dia.atividadesCardio.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Quitaste todos los ejercicios de este día.',
                  style: Theme.of(context).textTheme.bodySmall,
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

/// Linha de um exercício na ficha, com a opção de trocar por uma
/// alternativa mais leve do mesmo grupo ("aparelho ocupado", "hoje esse
/// movimento incomoda") sem esperar o check-in de progresso.
class _ExercicioTile extends StatelessWidget {
  const _ExercicioTile({
    required this.exibido,
    required this.original,
    required this.trocado,
    required this.aoTrocar,
    required this.aoDesfazerTroca,
  });

  final Exercicio exibido;
  final Exercicio original;
  final bool trocado;
  final void Function(Exercicio original) aoTrocar;
  final void Function(String exercicioOriginalId) aoDesfazerTroca;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(exibido.nome),
      subtitle: Text(
        trocado
            ? '${exibido.grupoMuscularPrincipal.label} · en lugar de ${original.nome}'
            : exibido.grupoMuscularPrincipal.label,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trocado)
            IconButton(
              key: Key('desfazer-troca-${original.id}'),
              tooltip: 'Volver al ejercicio original',
              icon: const Icon(Icons.undo),
              onPressed: () => aoDesfazerTroca(original.id),
            )
          else
            IconButton(
              key: Key('trocar-exercicio-${original.id}'),
              tooltip: 'Cambiar este ejercicio',
              icon: const Icon(Icons.swap_horiz),
              onPressed: () => aoTrocar(original),
            ),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ExercicioDetalheScreen(exercicio: exibido),
        ),
      ),
    );
  }
}
