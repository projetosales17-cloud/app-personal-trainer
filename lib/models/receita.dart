enum TipoRefeicao { cafeDaManha, almoco, lancheDaTarde, jantar }

extension TipoRefeicaoLabel on TipoRefeicao {
  String get label => switch (this) {
    TipoRefeicao.cafeDaManha => 'Desayuno',
    TipoRefeicao.almoco => 'Almuerzo',
    TipoRefeicao.lancheDaTarde => 'Merienda',
    TipoRefeicao.jantar => 'Cena',
  };
}

/// Uma receita da biblioteca. Sem informação calórica de propósito, como
/// os demais conteúdos de Alimentação (ver briefing do produto — a v1 não
/// faz contagem de calorias).
class Receita {
  const Receita({
    required this.id,
    required this.titulo,
    required this.tipoRefeicao,
    required this.tempoPreparoMinutos,
    required this.porcoes,
    required this.ingredientes,
    required this.modoPreparo,
    this.contemLactose = false,
    this.contemGluten = false,
    this.vegetariano = true,
    this.vegano = true,
  });

  final String id;
  final String titulo;
  final TipoRefeicao tipoRefeicao;
  final int tempoPreparoMinutos;
  final int porcoes;
  final List<String> ingredientes;
  final String modoPreparo;
  final bool contemLactose;
  final bool contemGluten;
  final bool vegetariano;
  final bool vegano;
}
