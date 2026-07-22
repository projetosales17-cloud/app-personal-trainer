import '../models/anamnese.dart';
import '../models/exercicio.dart';
import '../models/ficha_treino.dart';
import 'biblioteca_exercicios_repository.dart';

/// Gera uma ficha de treino a partir da anamnese, usando a biblioteca de
/// exercícios. É uma primeira versão simples de personalização — não
/// substitui a avaliação de um educador físico.
class GeradorFichaTreino {
  GeradorFichaTreino({BibliotecaExerciciosRepository? repositorio})
    : repositorio = repositorio ?? BibliotecaExerciciosRepository();

  final BibliotecaExerciciosRepository repositorio;

  static const duracaoValidadeDias = 30;
  static const _maxExerciciosPorGrupo = 3;

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

  /// Mapeia o objetivo principal da anamnese para a tag de objetivo usada
  /// na biblioteca de exercícios.
  static const _mapaObjetivo = {
    Objetivo.emagrecimento: ObjetivoExercicio.emagrecimento,
    Objetivo.tonificacao: ObjetivoExercicio.hipertrofia,
    Objetivo.hipertrofia: ObjetivoExercicio.hipertrofia,
    Objetivo.performanceAtletica: ObjetivoExercicio.forca,
    Objetivo.saudeGeral: ObjetivoExercicio.mobilidade,
    Objetivo.terceiraIdade: ObjetivoExercicio.mobilidade,
  };

  /// Perfil de terceira idade prioriza segurança: fora o nível avançado
  /// (maior risco de lesão sem supervisão presencial) e exercícios que
  /// exigem impacto/salto ou carga axial alta na coluna.
  static const _exerciciosInseguraTerceiraIdade = {
    'roda-abdominal',
    'barra-fixa-assistida',
    'elevacao-pelvica-barra',
  };

  /// Equipamentos disponíveis para quem treina em casa. Academia não tem
  /// restrição de equipamento.
  static const _equipamentosCasa = {Equipamento.nenhum, Equipamento.elastico};

  FichaTreino gerar(Anamnese anamnese) {
    final gruposExcluidos = anamnese.lesoesLimitacoes
        .map((lesao) => _mapaLesaoParaGrupo[lesao])
        .whereType<GrupoMuscular>()
        .toSet();

    final gruposDisponiveis = [
      for (final grupo in GrupoMuscular.values)
        if (!gruposExcluidos.contains(grupo)) grupo,
    ];

    final dias = anamnese.frequenciaSemanalDias.clamp(1, 7);
    final objetivoExercicio = _mapaObjetivo[anamnese.objetivoPrincipal]!;
    final equipamentosPermitidos = anamnese.localTreino == LocalTreino.casa
        ? _equipamentosCasa
        : null;
    final restringirTerceiraIdade = anamnese.objetivoPrincipal == Objetivo.terceiraIdade;

    final diasDeTreino = <DiaDeTreino>[];
    for (var indiceDia = 0; indiceDia < dias; indiceDia++) {
      final gruposDoDia = [
        for (var j = indiceDia; j < gruposDisponiveis.length; j += dias)
          gruposDisponiveis[j],
      ];
      final exercicios = <Exercicio>[
        for (final grupo in gruposDoDia)
          ..._escolherExercicios(
            grupo,
            objetivoExercicio,
            equipamentosPermitidos: equipamentosPermitidos,
            restringirTerceiraIdade: restringirTerceiraIdade,
          ),
      ];
      diasDeTreino.add(
        DiaDeTreino(dia: indiceDia + 1, gruposMusculares: gruposDoDia, exercicios: exercicios),
      );
    }

    final geradaEm = DateTime.now();
    return FichaTreino(
      dias: diasDeTreino,
      geradaEm: geradaEm,
      validaAte: geradaEm.add(const Duration(days: duracaoValidadeDias)),
    );
  }

  List<Exercicio> _escolherExercicios(
    GrupoMuscular grupo,
    ObjetivoExercicio objetivo, {
    Set<Equipamento>? equipamentosPermitidos,
    bool restringirTerceiraIdade = false,
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
    final comObjetivo = candidatos.where((exercicio) => exercicio.objetivos.contains(objetivo));
    final base = comObjetivo.isNotEmpty ? comObjetivo.toList() : candidatos;
    final ordenados = [...base]..sort((a, b) => a.nivel.index.compareTo(b.nivel.index));
    return ordenados.take(_maxExerciciosPorGrupo).toList();
  }
}
