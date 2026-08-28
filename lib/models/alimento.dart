enum CategoriaAlimento { proteina, carboidrato, gordura, vegetal, fruta, laticinio }

extension CategoriaAlimentoLabel on CategoriaAlimento {
  String get label => switch (this) {
    CategoriaAlimento.proteina => 'Proteína',
    CategoriaAlimento.carboidrato => 'Carbohidrato',
    CategoriaAlimento.gordura => 'Grasa buena',
    CategoriaAlimento.vegetal => 'Vegetal',
    CategoriaAlimento.fruta => 'Fruta',
    CategoriaAlimento.laticinio => 'Lácteo/sustituto',
  };
}

/// Comidas del día. Cada alimento sabe en cuáles cae bien — el arroz y los
/// frijoles son de la comida/cena, el pan y la tortilla son del desayuno y
/// la merienda, y así. Es lo que evita "arroz en el desayuno".
enum Refeicao { cafeDaManha, almoco, lancheTarde, jantar, ceia }

extension RefeicaoLabel on Refeicao {
  String get label => switch (this) {
    Refeicao.cafeDaManha => 'Desayuno',
    Refeicao.almoco => 'Almuerzo',
    Refeicao.lancheTarde => 'Merienda',
    Refeicao.jantar => 'Cena',
    Refeicao.ceia => 'Colación nocturna',
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

  /// En qué comidas cae bien este alimento. Por defecto: todas (para
  /// items neutros como frutas y frutos secos).
  final Set<Refeicao> refeicoes;

  /// Frijoles, lentejas, garbanzos. Son `proteina` en la categoría, pero
  /// el generador los trata como "los frijoles del plato" — acompañan a la
  /// proteína principal en la comida/cena, no la sustituyen.
  final bool leguminosa;

  final bool contemLactose;
  final bool contemGluten;
  final bool vegetariano;
  final bool vegano;
  final String? observacao;
}
