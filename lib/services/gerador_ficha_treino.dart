import '../models/anamnese.dart';
import '../models/atividade_cardio.dart';
import '../models/exercicio.dart';
import '../models/ficha_treino.dart';
import 'biblioteca_cardio_repository.dart';
import 'biblioteca_exercicios_repository.dart';

/// Configuração de treino por objetivo — a fonte que faz cada objetivo da
/// anamnese entregar um treino realmente diferente, e não só uma seleção
/// de exercícios parecida.
class _ConfigObjetivo {
  const _ConfigObjetivo({
    required this.tagExercicio,
    required this.prescricao,
    this.maxExerciciosPorGrupo = 3,
    this.evitarNivelAvancado = false,
  });

  /// Tag usada para filtrar exercícios da biblioteca.
  final ObjetivoExercicio tagExercicio;

  /// Séries/repetições/descanso sugeridos.
  final PrescricaoTreino prescricao;

  /// Volume-alvo por grupo muscular.
  final int maxExerciciosPorGrupo;

  /// Objetivos voltados a segurança/retomada não usam exercícios de nível
  /// avançado.
  final bool evitarNivelAvancado;
}

/// Gera uma ficha de treino a partir da anamnese, usando a biblioteca de
/// exercícios. É uma primeira versão simples de personalização — não
/// substitui a avaliação de um educador físico.
class GeradorFichaTreino {
  GeradorFichaTreino({
    BibliotecaExerciciosRepository? repositorio,
    BibliotecaCardioRepository? repositorioCardio,
  }) : repositorio = repositorio ?? BibliotecaExerciciosRepository(),
       repositorioCardio = repositorioCardio ?? BibliotecaCardioRepository();

  final BibliotecaExerciciosRepository repositorio;
  final BibliotecaCardioRepository repositorioCardio;

  static const duracaoValidadeDias = 30;

  /// Mapeia os textos de lesão coletados no onboarding para o grupo
  /// muscular correspondente, para excluir da ficha. Lesões digitadas em
  /// "Outra" (texto livre) não são reconhecidas aqui e não filtram nada.
  static const _mapaLesaoParaGrupo = {
    'Joelho': GrupoMuscular.perna,
    'Ombro': GrupoMuscular.ombro,
    'Coluna/lombar': GrupoMuscular.costas,
    'Punho': GrupoMuscular.biceps,
    'Tornozelo': GrupoMuscular.perna,
  };

  /// Mapeia os textos de "priorização de região" coletados no onboarding
  /// para os grupos musculares que ganham volume extra e entram primeiro
  /// na semana. Textos não reconhecidos são ignorados.
  static const _mapaRegiaoParaGrupos = {
    'Aumentar glúteo': [GrupoMuscular.gluteo],
    'Aumentar pernas': [GrupoMuscular.perna],
    'Diminuir braço': [GrupoMuscular.biceps, GrupoMuscular.triceps],
    'Diminuir abdômen': [GrupoMuscular.abdomen],
    'Fortalecer core': [GrupoMuscular.abdomen],
  };

  /// Perfil de terceira idade prioriza segurança: fora o nível avançado
  /// (maior risco de lesão sem supervisão presencial) e exercícios que
  /// exigem impacto/salto ou carga axial alta na coluna.
  static const _exerciciosInseguraTerceiraIdade = {
    'roda-abdominal',
    'barra-fixa-assistida',
    'elevacao-pelvica-barra',
  };

  /// Período de precaução pós-parto em que exercícios de abdômen ficam
  /// bloqueados por padrão (~12 semanas), até liberação médica — regra
  /// simples de segurança, não substitui avaliação profissional (ver
  /// briefing do produto).
  static const _diasRestricaoAbdomenPosParto = 84;

  static const _configPorObjetivo = <Objetivo, _ConfigObjetivo>{
    Objetivo.emagrecimento: _ConfigObjetivo(
      tagExercicio: ObjetivoExercicio.emagrecimento,
      prescricao: PrescricaoTreino(
        series: '3 séries',
        repeticoes: '12 a 15 repetições',
        descanso: '30 a 45 segundos entre séries',
        estilo:
            'Circuito em ritmo constante: descansos curtos para manter o gasto calórico alto.',
      ),
    ),
    Objetivo.recomposicao: _ConfigObjetivo(
      tagExercicio: ObjetivoExercicio.hipertrofia,
      prescricao: PrescricaoTreino(
        series: '3 a 4 séries',
        repeticoes: '10 a 12 repetições',
        descanso: '45 a 60 segundos entre séries',
        estilo:
            'Cargas moderadas com pouco descanso: estimula o músculo enquanto reduz gordura.',
      ),
    ),
    Objetivo.tonificacao: _ConfigObjetivo(
      tagExercicio: ObjetivoExercicio.hipertrofia,
      prescricao: PrescricaoTreino(
        series: '3 séries',
        repeticoes: '15 a 20 repetições',
        descanso: '30 a 45 segundos entre séries',
        estilo:
            'Muitas repetições com carga leve a moderada: firmeza e resistência muscular.',
      ),
    ),
    Objetivo.gluteoPernas: _ConfigObjetivo(
      tagExercicio: ObjetivoExercicio.hipertrofia,
      maxExerciciosPorGrupo: 3,
      prescricao: PrescricaoTreino(
        series: '3 a 4 séries',
        repeticoes: '10 a 15 repetições',
        descanso: '45 a 60 segundos entre séries',
        estilo:
            'Mais volume para glúteo e pernas, que entram primeiro na semana.',
      ),
    ),
    Objetivo.hipertrofia: _ConfigObjetivo(
      tagExercicio: ObjetivoExercicio.hipertrofia,
      prescricao: PrescricaoTreino(
        series: '3 a 4 séries',
        repeticoes: '8 a 12 repetições',
        descanso: '60 a 90 segundos entre séries',
        estilo:
            'Cargas exigentes e descanso completo: o foco é o crescimento muscular.',
      ),
    ),
    Objetivo.performanceAtletica: _ConfigObjetivo(
      tagExercicio: ObjetivoExercicio.forca,
      prescricao: PrescricaoTreino(
        series: '4 a 5 séries',
        repeticoes: '4 a 6 repetições',
        descanso: '2 a 3 minutos entre séries',
        estilo: 'Cargas altas e poucas repetições: força e potência.',
      ),
    ),
    Objetivo.voltarATreinar: _ConfigObjetivo(
      tagExercicio: ObjetivoExercicio.mobilidade,
      maxExerciciosPorGrupo: 2,
      evitarNivelAvancado: true,
      prescricao: PrescricaoTreino(
        series: '2 séries',
        repeticoes: '12 a 15 repetições',
        descanso: '60 segundos entre séries',
        estilo:
            'Volume baixo e movimentos simples: criar constância sem sobrecarregar o corpo.',
      ),
    ),
    Objetivo.saudeGeral: _ConfigObjetivo(
      tagExercicio: ObjetivoExercicio.mobilidade,
      evitarNivelAvancado: true,
      prescricao: PrescricaoTreino(
        series: '2 a 3 séries',
        repeticoes: '12 a 15 repetições',
        descanso: '45 a 60 segundos entre séries',
        estilo: 'Ritmo confortável, com foco em se mover bem e com regularidade.',
      ),
    ),
    Objetivo.menopausa: _ConfigObjetivo(
      tagExercicio: ObjetivoExercicio.hipertrofia,
      evitarNivelAvancado: true,
      prescricao: PrescricaoTreino(
        series: '2 a 3 séries',
        repeticoes: '8 a 12 repetições',
        descanso: '60 a 90 segundos entre séries',
        estilo:
            'Força com cargas moderadas para preservar músculo e massa óssea.',
      ),
    ),
    Objetivo.terceiraIdade: _ConfigObjetivo(
      tagExercicio: ObjetivoExercicio.mobilidade,
      maxExerciciosPorGrupo: 2,
      prescricao: PrescricaoTreino(
        series: '2 séries',
        repeticoes: '10 a 12 repetições',
        descanso: 'o tempo que precisar para se recuperar',
        estilo: 'Movimentos controlados, com foco em equilíbrio e mobilidade.',
      ),
    ),
  };

  /// [reduzirVolumeRetomada] vem do `MotorAderencia` (ver briefing do
  /// produto): quando a usuária pulou treinos consecutivos, a próxima
  /// ficha vem com volume reduzido e sem nível avançado, como uma sessão
  /// de retomada mais leve.
  FichaTreino gerar(Anamnese anamnese, {bool reduzirVolumeRetomada = false}) {
    final config = _configPorObjetivo[anamnese.objetivoPrincipal]!;

    final emRestricaoAbdomenPosParto = anamnese.dataParto != null &&
        DateTime.now().difference(anamnese.dataParto!).inDays < _diasRestricaoAbdomenPosParto;

    final gruposExcluidos = anamnese.lesoesLimitacoes
        .map((lesao) => _mapaLesaoParaGrupo[lesao])
        .whereType<GrupoMuscular>()
        .toSet();
    if (emRestricaoAbdomenPosParto) {
      gruposExcluidos.add(GrupoMuscular.abdomen);
    }

    final gruposPriorizados = anamnese.regioesPriorizadas
        .expand((regiao) => _mapaRegiaoParaGrupos[regiao] ?? const <GrupoMuscular>[])
        .where((grupo) => !gruposExcluidos.contains(grupo))
        .toSet();

    final disponiveis = [
      for (final grupo in GrupoMuscular.values)
        if (!gruposExcluidos.contains(grupo)) grupo,
    ];
    // Grupos priorizados entram primeiro na semana (mantendo a ordem
    // relativa original entre eles), o resto vem depois.
    final gruposDisponiveis = [
      ...disponiveis.where(gruposPriorizados.contains),
      ...disponiveis.where((grupo) => !gruposPriorizados.contains(grupo)),
    ];

    final dias = anamnese.frequenciaSemanalDias.clamp(1, 7);
    final objetivoExercicio = config.tagExercicio;
    final equipamentosPermitidos = anamnese.localTreino == LocalTreino.casa
        ? equipamentosCasa
        : null;
    final restringirTerceiraIdade = anamnese.objetivoPrincipal == Objetivo.terceiraIdade;

    // Ajuste por fase do ciclo hormonal (ver briefing do produto): fase
    // menstrual reduz volume (menos exercícios por grupo) e intensidade
    // (sem nível avançado); fase lútea só reduz intensidade. Folicular e
    // ovulação não têm restrição — são as fases de mais energia/força.
    final faseCiclo = anamnese.faseCiclo;
    final excluirNivelAvancado = config.evitarNivelAvancado ||
        faseCiclo == FaseCiclo.menstrual ||
        faseCiclo == FaseCiclo.lutea ||
        reduzirVolumeRetomada;
    final reduzirVolume = faseCiclo == FaseCiclo.menstrual || reduzirVolumeRetomada;

    int maxParaGrupo(GrupoMuscular grupo) {
      var max = config.maxExerciciosPorGrupo;
      if (gruposPriorizados.contains(grupo)) max += 1;
      if (reduzirVolume) max -= 1;
      return max.clamp(1, 99);
    }

    final incluirMusculacao = anamnese.preferenciaTreino != PreferenciaTreino.soCardio;
    final incluirCardio = anamnese.preferenciaTreino != PreferenciaTreino.soMusculacao;
    final candidatosCardio = incluirCardio
        ? repositorioCardio.filtrar(local: anamnese.localTreino)
        : const <AtividadeCardio>[];

    final diasDeTreino = <DiaDeTreino>[];
    for (var indiceDia = 0; indiceDia < dias; indiceDia++) {
      final gruposDoDia = incluirMusculacao
          ? [
              for (var j = indiceDia; j < gruposDisponiveis.length; j += dias)
                gruposDisponiveis[j],
            ]
          : const <GrupoMuscular>[];
      final exercicios = <Exercicio>[
        for (final grupo in gruposDoDia)
          ..._escolherExercicios(
            grupo,
            objetivoExercicio,
            equipamentosPermitidos: equipamentosPermitidos,
            restringirTerceiraIdade: restringirTerceiraIdade,
            excluirNivelAvancado: excluirNivelAvancado,
            maxExercicios: maxParaGrupo(grupo),
          ),
      ];
      final atividadesCardio = candidatosCardio.isNotEmpty
          ? [candidatosCardio[indiceDia % candidatosCardio.length]]
          : const <AtividadeCardio>[];
      diasDeTreino.add(
        DiaDeTreino(
          dia: indiceDia + 1,
          gruposMusculares: gruposDoDia,
          exercicios: exercicios,
          atividadesCardio: atividadesCardio,
        ),
      );
    }

    final geradaEm = DateTime.now();
    return FichaTreino(
      dias: diasDeTreino,
      geradaEm: geradaEm,
      validaAte: geradaEm.add(const Duration(days: duracaoValidadeDias)),
      prescricao: config.prescricao,
    );
  }

  List<Exercicio> _escolherExercicios(
    GrupoMuscular grupo,
    ObjetivoExercicio objetivo, {
    Set<Equipamento>? equipamentosPermitidos,
    bool restringirTerceiraIdade = false,
    bool excluirNivelAvancado = false,
    required int maxExercicios,
  }) {
    var candidatos = repositorio.filtrar(grupoMuscular: grupo);
    if (equipamentosPermitidos != null) {
      candidatos = candidatos
          .where((exercicio) => equipamentosPermitidos.contains(exercicio.equipamento))
          .toList();
    }
    if (restringirTerceiraIdade) {
      candidatos = candidatos
          .where(
            (exercicio) =>
                exercicio.nivel != NivelExercicio.avancado &&
                !_exerciciosInseguraTerceiraIdade.contains(exercicio.id),
          )
          .toList();
    } else if (excluirNivelAvancado) {
      candidatos = candidatos
          .where((exercicio) => exercicio.nivel != NivelExercicio.avancado)
          .toList();
    }
    final comObjetivo = candidatos.where((exercicio) => exercicio.objetivos.contains(objetivo));
    final base = comObjetivo.isNotEmpty ? comObjetivo.toList() : candidatos;
    final ordenados = [...base]..sort((a, b) => a.nivel.index.compareTo(b.nivel.index));
    return ordenados.take(maxExercicios).toList();
  }
}
