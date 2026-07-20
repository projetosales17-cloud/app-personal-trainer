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
  };

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

    final diasDeTreino = <DiaDeTreino>[];
    for (var indiceDia = 0; indiceDia < dias; indiceDia++) {
      final gruposDoDia = [
        for (var j = indiceDia; j < gruposDisponiveis.length; j += dias)
          gruposDisponiveis[j],
      ];
      final exercicios = <Exercicio>[
        for (final grupo in gruposDoDia)
          ..._escolherExercicios(grupo, objetivoExercicio),
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

  List<Exercicio> _escolherExercicios(GrupoMuscular grupo, ObjetivoExercicio objetivo) {
    final candidatos = repositorio.filtrar(grupoMuscular: grupo);
    final comObjetivo = candidatos.where((exercicio) => exercicio.objetivos.contains(objetivo));
    final base = comObjetivo.isNotEmpty ? comObjetivo.toList() : candidatos;
    final ordenados = [...base]..sort((a, b) => a.nivel.index.compareTo(b.nivel.index));
    return ordenados.take(_maxExerciciosPorGrupo).toList();
  }
}
