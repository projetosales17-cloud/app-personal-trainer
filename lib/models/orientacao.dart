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

/// Um conteúdo pré-gravado da biblioteca de Orientações. `urlVideo` fica
/// nulo por enquanto — só texto na v1 (ver briefing do produto).
class Orientacao {
  const Orientacao({
    required this.id,
    required this.titulo,
    required this.tema,
    required this.corpo,
    this.urlVideo,
  });

  final String id;
  final String titulo;
  final TemaOrientacao tema;
  final String corpo;
  final String? urlVideo;
}
