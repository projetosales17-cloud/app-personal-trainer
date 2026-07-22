import 'anamnese.dart' show LocalTreino;

export 'anamnese.dart' show LocalTreino;

/// Uma atividade de cardio da biblioteca. `baixoImpacto` marca atividades
/// seguras para o perfil de terceira idade (sem salto/impacto articular
/// alto) — ver GeradorFichaTreino.
class AtividadeCardio {
  const AtividadeCardio({
    required this.id,
    required this.nome,
    required this.local,
    required this.baixoImpacto,
    required this.instrucoes,
    this.duracaoMinutosSugerida = 20,
  });

  final String id;
  final String nome;
  final LocalTreino local;
  final bool baixoImpacto;
  final String instrucoes;
  final int duracaoMinutosSugerida;
}
