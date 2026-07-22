enum GrupoMuscular {
  peito,
  costas,
  ombro,
  biceps,
  triceps,
  perna,
  gluteo,
  abdomen,
}

extension GrupoMuscularLabel on GrupoMuscular {
  String get label => switch (this) {
    GrupoMuscular.peito => 'Peito',
    GrupoMuscular.costas => 'Costas',
    GrupoMuscular.ombro => 'Ombro',
    GrupoMuscular.biceps => 'Bíceps',
    GrupoMuscular.triceps => 'Tríceps',
    GrupoMuscular.perna => 'Perna',
    GrupoMuscular.gluteo => 'Glúteo',
    GrupoMuscular.abdomen => 'Abdômen',
  };

  /// Ilustração genérica usada como proxy visual enquanto não existe uma
  /// imagem real por exercício (ver Exercicio.caminhoImagem) — uma por
  /// grupo muscular, com a personagem consistente do app (ver
  /// docs/personagem-ia-exercicios.md), não por exercício individual.
  String get ilustracaoPadrao => switch (this) {
    GrupoMuscular.peito => 'assets/personagem/peito.jpg',
    GrupoMuscular.costas => 'assets/personagem/costas.jpg',
    GrupoMuscular.ombro => 'assets/personagem/ombro.jpg',
    GrupoMuscular.biceps => 'assets/personagem/biceps.jpg',
    GrupoMuscular.triceps => 'assets/personagem/triceps.jpg',
    GrupoMuscular.perna => 'assets/personagem/perna.jpg',
    GrupoMuscular.gluteo => 'assets/personagem/gluteo.jpg',
    GrupoMuscular.abdomen => 'assets/personagem/abdomen.jpg',
  };
}

enum NivelExercicio { iniciante, intermediario, avancado }

extension NivelExercicioLabel on NivelExercicio {
  String get label => switch (this) {
    NivelExercicio.iniciante => 'Iniciante',
    NivelExercicio.intermediario => 'Intermediário',
    NivelExercicio.avancado => 'Avançado',
  };
}

enum ObjetivoExercicio { hipertrofia, emagrecimento, forca, mobilidade }

extension ObjetivoExercicioLabel on ObjetivoExercicio {
  String get label => switch (this) {
    ObjetivoExercicio.hipertrofia => 'Hipertrofia',
    ObjetivoExercicio.emagrecimento => 'Emagrecimento/circuito',
    ObjetivoExercicio.forca => 'Força',
    ObjetivoExercicio.mobilidade => 'Mobilidade',
  };
}

enum Equipamento { nenhum, halteres, barra, elastico, maquina, banco, outro }

extension EquipamentoLabel on Equipamento {
  String get label => switch (this) {
    Equipamento.nenhum => 'Peso do corpo',
    Equipamento.halteres => 'Halteres',
    Equipamento.barra => 'Barra',
    Equipamento.elastico => 'Elástico',
    Equipamento.maquina => 'Máquina/cabo',
    Equipamento.banco => 'Banco',
    Equipamento.outro => 'Outro',
  };
}

/// Um exercício da biblioteca. `caminhoImagem` fica nulo por enquanto para
/// todos os exercícios — a demonstração visual foi decidida como imagem
/// gerada por IA (personagem consistente), não vídeo/GIF nem banco de
/// imagens licenciado (ver briefing do produto), mas a produção real
/// dessas imagens é um passo externo que ainda não aconteceu. Quando
/// existir, é um asset local do app (conteúdo pré-gravado, sem custo
/// recorrente de geração por usuária).
class Exercicio {
  const Exercicio({
    required this.id,
    required this.nome,
    required this.grupoMuscularPrincipal,
    this.gruposMuscularesSecundarios = const [],
    required this.nivel,
    required this.objetivos,
    required this.equipamento,
    required this.instrucoes,
    this.caminhoImagem,
  });

  final String id;
  final String nome;
  final GrupoMuscular grupoMuscularPrincipal;
  final List<GrupoMuscular> gruposMuscularesSecundarios;
  final NivelExercicio nivel;
  final List<ObjetivoExercicio> objetivos;
  final Equipamento equipamento;
  final String instrucoes;
  final String? caminhoImagem;
}
