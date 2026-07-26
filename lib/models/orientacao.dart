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
/// (pergunta em `titulo`, resposta em `corpo`), conforme `tipo`.
/// `caminhoVideo` aponta para um vídeo curto em loop (asset local, sem
/// áudio/narração) usado como fundo animado da Yara na tela de vídeo — o
/// texto de `titulo`/`corpo` é sobreposto nativamente pelo Flutter por
/// cima, não faz parte do arquivo de vídeo. Um mesmo vídeo é reaproveitado
/// por todo conteúdo do mesmo `tema`.
class Orientacao {
  const Orientacao({
    required this.id,
    required this.titulo,
    required this.tema,
    required this.corpo,
    this.tipo = TipoConteudoOrientacao.artigo,
    this.caminhoVideo,
  });

  final String id;
  final String titulo;
  final TemaOrientacao tema;
  final String corpo;
  final TipoConteudoOrientacao tipo;
  final String? caminhoVideo;
}
