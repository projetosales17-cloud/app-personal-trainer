enum CategoriaAlimento { proteina, carboidrato, gordura, vegetal, fruta, laticinio }

extension CategoriaAlimentoLabel on CategoriaAlimento {
  String get label => switch (this) {
    CategoriaAlimento.proteina => 'Proteína',
    CategoriaAlimento.carboidrato => 'Carboidrato',
    CategoriaAlimento.gordura => 'Gordura boa',
    CategoriaAlimento.vegetal => 'Vegetal',
    CategoriaAlimento.fruta => 'Fruta',
    CategoriaAlimento.laticinio => 'Laticínio/substituto',
  };
}

/// Refeições do dia. Cada alimento sabe em quais delas cai bem — arroz e
/// feijão são de almoço/jantar, pão e tapioca são de café da manhã e
/// lanche, e assim por diante. É o que evita "arroz no café da manhã".
enum Refeicao { cafeDaManha, almoco, lancheTarde, jantar, ceia }

extension RefeicaoLabel on Refeicao {
  String get label => switch (this) {
    Refeicao.cafeDaManha => 'Café da manhã',
    Refeicao.almoco => 'Almoço',
    Refeicao.lancheTarde => 'Lanche da tarde',
    Refeicao.jantar => 'Jantar',
    Refeicao.ceia => 'Ceia',
  };
}

/// Um alimento da biblioteca, usado para consulta e substituição dentro da
/// mesma categoria. Sem informação calórica de propósito — o diário
/// alimentar da v1 não faz contagem de calorias (ver briefing do produto).
class Alimento {
  const Alimento({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.porcaoSugerida,
    this.refeicoes = const {
      Refeicao.cafeDaManha,
      Refeicao.almoco,
      Refeicao.lancheTarde,
      Refeicao.jantar,
      Refeicao.ceia,
    },
    this.leguminosa = false,
    this.contemLactose = false,
    this.contemGluten = false,
    this.vegetariano = true,
    this.vegano = true,
    this.observacao,
  });

  final String id;
  final String nome;
  final CategoriaAlimento categoria;
  final String porcaoSugerida;

  /// Em quais refeições esse alimento cai bem. Padrão: todas (pra itens
  /// neutros como frutas e oleaginosas).
  final Set<Refeicao> refeicoes;

  /// Feijão, lentilha, grão-de-bico. São `proteina` na categoria, mas o
  /// gerador trata como o "feijão do prato" — acompanham a proteína
  /// principal no almoço/jantar, não a substituem.
  final bool leguminosa;

  final bool contemLactose;
  final bool contemGluten;
  final bool vegetariano;
  final bool vegano;
  final String? observacao;
}
