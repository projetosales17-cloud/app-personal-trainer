enum TipoSuplemento { proteina, creatina, vitaminaMineral, acidoGraxo }

extension TipoSuplementoLabel on TipoSuplemento {
  String get label => switch (this) {
    TipoSuplemento.proteina => 'Proteína',
    TipoSuplemento.creatina => 'Creatina',
    TipoSuplemento.vitaminaMineral => 'Vitamina/mineral',
    TipoSuplemento.acidoGraxo => 'Ácido graxo',
  };
}

/// Conteúdo educativo genérico sobre um suplemento — o que é e para que
/// serve em linhas gerais, sem dosagem, horário de uso ou recomendação
/// individualizada (ver briefing do produto: precisa de validação
/// profissional antes de virar conteúdo prescritivo, mesmo padrão já
/// aplicado à trilha pós-bariátrica em Orientações).
class Suplemento {
  const Suplemento({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.descricao,
  });

  final String id;
  final String nome;
  final TipoSuplemento tipo;
  final String descricao;
}
