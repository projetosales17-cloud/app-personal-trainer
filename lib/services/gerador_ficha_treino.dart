import '../models/anamnese.dart';
import '../models/atividade_cardio.dart';
import '../models/estrategia_bloco.dart';
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

  /// Mapeia os textos de lesão coletados no onboarding para os grupos
  /// musculares afetados, para excluir da ficha. Lesões digitadas em
  /// "Outra" (texto livre) não são reconhecidas aqui — para essas, a
  /// usuária usa a etapa "Grupos que prefere não treinar" (gruposEvitar).
  static const _mapaLesaoParaGrupos = <String, List<GrupoMuscular>>{
    'Joelho': [GrupoMuscular.perna],
    'Ombro': [GrupoMuscular.ombro],
    'Cotovelo': [GrupoMuscular.biceps, GrupoMuscular.triceps],
    'Coluna/lombar': [GrupoMuscular.costas],
    'Punho': [GrupoMuscular.biceps],
    'Tornozelo': [GrupoMuscular.perna],
  };

  static GrupoMuscular? _grupoPorNome(String nome) {
    for (final g in GrupoMuscular.values) {
      if (g.name == nome) return g;
    }
    return null;
  }

  /// Grupos musculares que ficam de fora da ficha por causa das lesões
  /// selecionadas e dos grupos que a usuária marcou para evitar — para a
  /// tela mostrar "Treino ajustado: sem Ombro, Bíceps". Não inclui a
  /// restrição temporária de abdômen pós-parto (essa tem aviso próprio).
  static List<GrupoMuscular> gruposEvitadosDe(Anamnese anamnese) {
    final grupos = <GrupoMuscular>{
      for (final lesao in anamnese.lesoesLimitacoes) ...?_mapaLesaoParaGrupos[lesao],
      for (final nome in anamnese.gruposEvitar) ?_grupoPorNome(nome),
    };
    return [for (final g in GrupoMuscular.values) if (grupos.contains(g)) g];
  }

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
  ///
  /// [estrategiaBloco] vem do `ProgramaTreinoRepository` (programa de longo
  /// prazo): define a fase da periodização, o volume extra/reduzido, o teto
  /// de nível, a rotação de exercícios e grupos a evitar por dor relatada
  /// no check-in. Quando `null`, a ficha é gerada sem progressão de
  /// programa (comportamento antigo — usado em testes e telas que não
  /// dependem do programa).
  FichaTreino gerar(
    Anamnese anamnese, {
    bool reduzirVolumeRetomada = false,
    EstrategiaBloco? estrategiaBloco,
  }) {
    final config = _configPorObjetivo[anamnese.objetivoPrincipal]!;

    final emRestricaoAbdomenPosParto = anamnese.dataParto != null &&
        DateTime.now().difference(anamnese.dataParto!).inDays < _diasRestricaoAbdomenPosParto;

    // Lesões selecionadas + grupos que a usuária marcou para não treinar
    // (lesão fora da lista, recomendação médica, ou só preferência).
    final gruposExcluidos = gruposEvitadosDe(anamnese).toSet();
    if (emRestricaoAbdomenPosParto) {
      gruposExcluidos.add(GrupoMuscular.abdomen);
    }
    if (estrategiaBloco != null) {
      gruposExcluidos.addAll(estrategiaBloco.gruposExcluidosExtra);
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

    // Teto de nível: o menor entre o que a fase do programa permite e o que
    // o ciclo/retomada permite.
    var tetoNivel = estrategiaBloco?.tetoNivel ?? NivelExercicio.avancado;
    if (excluirNivelAvancado && tetoNivel == NivelExercicio.avancado) {
      tetoNivel = NivelExercicio.intermediario;
    }
    final rotacaoOffset = estrategiaBloco?.rotacaoOffset ?? 0;

    int maxParaGrupo(GrupoMuscular grupo) {
      var max = config.maxExerciciosPorGrupo + (estrategiaBloco?.volumeModificador ?? 0);
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
            tetoNivel: tetoNivel,
            rotacaoOffset: rotacaoOffset,
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
    NivelExercicio tetoNivel = NivelExercicio.avancado,
    int rotacaoOffset = 0,
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
    }
    candidatos = candidatos
        .where((exercicio) => exercicio.nivel.index <= tetoNivel.index)
        .toList();

    final comObjetivo = candidatos.where((exercicio) => exercicio.objetivos.contains(objetivo));
    final base = comObjetivo.isNotEmpty ? comObjetivo.toList() : candidatos;
    var ordenados = [...base]..sort((a, b) => a.nivel.index.compareTo(b.nivel.index));

    // Rotação por bloco: gira a lista para não repetir sempre os mesmos
    // exercícios ao longo dos meses.
    if (rotacaoOffset > 0 && ordenados.length > 1) {
      final o = rotacaoOffset % ordenados.length;
      ordenados = [...ordenados.skip(o), ...ordenados.take(o)];
    }

    return ordenados.take(maxExercicios).toList();
  }
}
