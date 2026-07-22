enum TemaOrientacao { treino, alimentacao, motivacao, menopausa, posBariatrica, habitos }

extension TemaOrientacaoLabel on TemaOrientacao {
  String get label => switch (this) {
    TemaOrientacao.treino => 'Treino',
    TemaOrientacao.alimentacao => 'Alimentação',
    TemaOrientacao.motivacao => 'Motivação',
    TemaOrientacao.menopausa => 'Menopausa',
    TemaOrientacao.posBariatrica => 'Pós-bariátrica',
    TemaOrientacao.habitos => 'Hábitos saudáveis',
  };
}

enum TipoConteudoOrientacao { artigo, faq }

extension TipoConteudoOrientacaoLabel on TipoConteudoOrientacao {
  String get label => switch (this) {
    TipoConteudoOrientacao.artigo => 'Artigo',
    TipoConteudoOrientacao.faq => 'FAQ',
  };
}

/// Um conteúdo pré-gravado da biblioteca de Orientações — artigo ou FAQ
/// (pergunta em `titulo`, resposta em `corpo`), conforme `tipo`. `urlVideo`
/// fica nulo para toda a biblioteca por enquanto — produção de vídeos
/// curtos é um passo de conteúdo externo ainda pendente (ver briefing do
/// produto: "artigos por tema, FAQ e vídeos curtos").
class Orientacao {
  const Orientacao({
    required this.id,
    required this.titulo,
    required this.tema,
    required this.corpo,
    this.tipo = TipoConteudoOrientacao.artigo,
    this.urlVideo,
  });

  final String id;
  final String titulo;
  final TemaOrientacao tema;
  final String corpo;
  final TipoConteudoOrientacao tipo;
  final String? urlVideo;
}
