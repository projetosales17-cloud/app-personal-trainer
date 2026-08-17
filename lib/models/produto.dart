/// Tags de perfil da anamnese usadas para segmentar o catálogo (ver
/// briefing do produto) — hoje só filtram a vitrine; a recomendação
/// cruzada automática por perfil fica para quando a gamificação
/// existir de verdade.
enum TagPerfil { emagrecimento, hipertrofia, menopausa, terceiraIdade, bariatrica }

extension TagPerfilLabel on TagPerfil {
  String get label => switch (this) {
    TagPerfil.emagrecimento => 'Pérdida de peso',
    TagPerfil.hipertrofia => 'Hipertrofia',
    TagPerfil.menopausa => 'Menopausia',
    TagPerfil.terceiraIdade => 'Adultos mayores',
    TagPerfil.bariatrica => 'Posbariátrica',
  };
}

/// Item do catálogo informativo da vitrine. `linkExterno` fica nulo até
/// existir uma loja/parceria real (ver briefing do produto: ainda não há
/// empresa aberta nem plataforma de loja escolhida) — o botão de compra
/// mostra "Em breve" nesse caso.
class Produto {
  const Produto({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.faixaPrecoReferencia,
    this.tags = const [],
    this.linkExterno,
  });

  final String id;
  final String nome;
  final String descricao;
  final String faixaPrecoReferencia;
  final List<TagPerfil> tags;
  final String? linkExterno;
}
