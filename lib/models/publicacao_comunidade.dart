enum TipoPublicacaoComunidade { depoimento, dica, conquista }

extension TipoPublicacaoComunidadeLabel on TipoPublicacaoComunidade {
  String get label => switch (this) {
    TipoPublicacaoComunidade.depoimento => 'Depoimento',
    TipoPublicacaoComunidade.dica => 'Dica',
    TipoPublicacaoComunidade.conquista => 'Conquista',
  };
}

/// Uma publicação da aba Comunidade: conteúdo curado e pré-escrito (mesmo
/// padrão de Orientações), não gerado por usuárias reais. Uma comunidade
/// de verdade (postar, comentar, curtir) exigiria moderação de conteúdo e
/// uma decisão de backend ainda não tomada (ver briefing do produto) — v1
/// é só um feed de leitura para dar a sensação de comunidade/motivação.
class PublicacaoComunidade {
  const PublicacaoComunidade({
    required this.id,
    required this.autora,
    required this.tipo,
    required this.texto,
  });

  final String id;
  final String autora;
  final TipoPublicacaoComunidade tipo;
  final String texto;
}
