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

/// Um alimento da biblioteca, usado para consulta e substituição dentro da
/// mesma categoria. Sem informação calórica de propósito — o diário
/// alimentar da v1 não faz contagem de calorias (ver briefing do produto).
class Alimento {
  const Alimento({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.porcaoSugerida,
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
  final bool contemLactose;
  final bool contemGluten;
  final bool vegetariano;
  final bool vegano;
  final String? observacao;
}
