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
    GrupoMuscular.peito => 'Pecho',
    GrupoMuscular.costas => 'Espalda',
    GrupoMuscular.ombro => 'Hombro',
    GrupoMuscular.biceps => 'Bíceps',
    GrupoMuscular.triceps => 'Tríceps',
    GrupoMuscular.perna => 'Pierna',
    GrupoMuscular.gluteo => 'Glúteo',
    GrupoMuscular.abdomen => 'Abdomen',
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
    NivelExercicio.iniciante => 'Principiante',
    NivelExercicio.intermediario => 'Intermedio',
    NivelExercicio.avancado => 'Avanzado',
  };
}

enum ObjetivoExercicio { hipertrofia, emagrecimento, forca, mobilidade }

extension ObjetivoExercicioLabel on ObjetivoExercicio {
  String get label => switch (this) {
    ObjetivoExercicio.hipertrofia => 'Hipertrofia',
    ObjetivoExercicio.emagrecimento => 'Pérdida de peso/circuito',
    ObjetivoExercicio.forca => 'Fuerza',
    ObjetivoExercicio.mobilidade => 'Movilidad',
  };
}

enum Equipamento { nenhum, halteres, barra, elastico, maquina, banco, outro }

extension EquipamentoLabel on Equipamento {
  String get label => switch (this) {
    Equipamento.nenhum => 'Peso corporal',
    Equipamento.halteres => 'Mancuernas',
    Equipamento.barra => 'Barra',
    Equipamento.elastico => 'Banda elástica',
    Equipamento.maquina => 'Máquina/polea',
    Equipamento.banco => 'Banco',
    Equipamento.outro => 'Otro',
  };
}

/// Equipamentos que quem treina em casa normalmente tem à mão (peso do
/// corpo e faixa elástica). Fonte única usada tanto pelo gerador de ficha
/// quanto pelo filtro "en casa" da biblioteca de exercícios.
const equipamentosCasa = {Equipamento.nenhum, Equipamento.elastico};

/// Um exercício da biblioteca. `caminhoImagem` aponta para a imagem de
/// demonstração — asset local do app (`assets/personagem/<id>.jpg`),
/// ilustração da personagem consistente gerada por IA (personagem
/// consistente, não vídeo/GIF nem banco de imagens licenciado — ver
/// briefing do produto). Fica nulo só para exercícios ainda sem imagem
/// própria, e aí a tela cai na ilustração genérica do grupo muscular.
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
