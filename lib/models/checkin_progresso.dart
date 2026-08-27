/// Quanto a usuária conseguiu treinar no bloco que está terminando.
enum AderenciaPercebida { quaseTudo, maisOuMenos, pouco }

/// Como o treino tem sido em termos de dificuldade.
enum DificuldadeTreino { facilDemais, naMedida, dificilDemais }

/// Como a usuária tem se sentido em termos de recuperação/energia.
enum Recuperacao { bemRecuperada, umPoucoCansada, muitoCansada }

extension AderenciaPercebidaLabel on AderenciaPercebida {
  String get label => switch (this) {
    AderenciaPercebida.quaseTudo => 'Consegui treinar quase tudo',
    AderenciaPercebida.maisOuMenos => 'Treinei mais ou menos a metade',
    AderenciaPercebida.pouco => 'Treinei pouco',
  };
}

extension DificuldadeTreinoLabel on DificuldadeTreino {
  String get label => switch (this) {
    DificuldadeTreino.facilDemais => 'Fácil demais',
    DificuldadeTreino.naMedida => 'Na medida',
    DificuldadeTreino.dificilDemais => 'Difícil demais',
  };
}

extension RecuperacaoLabel on Recuperacao {
  String get label => switch (this) {
    Recuperacao.bemRecuperada => 'Bem recuperada',
    Recuperacao.umPoucoCansada => 'Um pouco cansada',
    Recuperacao.muitoCansada => 'Muito cansada',
  };
}

/// Respostas do questionário de progresso que a usuária preenche ao fim de
/// cada bloco de treino (~6 semanas). É a base para o app decidir a
/// estratégia da próxima ficha (ver `EstrategiaBloco`).
class CheckinProgresso {
  const CheckinProgresso({
    required this.data,
    required this.blocoConcluido,
    required this.aderencia,
    required this.dificuldade,
    required this.recuperacao,
    required this.dorNova,
    this.regiaoDorNova,
    required this.notaDiferenca,
    required this.objetivoMudou,
    this.pesoKg,
    this.cinturaCm,
    this.quadrilCm,
    this.bracoCm,
    this.coxaCm,
  });

  final DateTime data;
  final int blocoConcluido;
  final AderenciaPercebida aderencia;
  final DificuldadeTreino dificuldade;
  final Recuperacao recuperacao;
  final bool dorNova;
  final String? regiaoDorNova;
  final bool notaDiferenca;
  final bool objetivoMudou;
  final double? pesoKg;
  final double? cinturaCm;
  final double? quadrilCm;
  final double? bracoCm;
  final double? coxaCm;

  Map<String, dynamic> toJson() => {
    'data': data.toIso8601String(),
    'blocoConcluido': blocoConcluido,
    'aderencia': aderencia.name,
    'dificuldade': dificuldade.name,
    'recuperacao': recuperacao.name,
    'dorNova': dorNova,
    'regiaoDorNova': regiaoDorNova,
    'notaDiferenca': notaDiferenca,
    'objetivoMudou': objetivoMudou,
    'pesoKg': pesoKg,
    'cinturaCm': cinturaCm,
    'quadrilCm': quadrilCm,
    'bracoCm': bracoCm,
    'coxaCm': coxaCm,
  };

  factory CheckinProgresso.fromJson(Map<String, dynamic> json) => CheckinProgresso(
    data: DateTime.parse(json['data'] as String),
    blocoConcluido: json['blocoConcluido'] as int,
    aderencia: AderenciaPercebida.values.byName(json['aderencia'] as String),
    dificuldade: DificuldadeTreino.values.byName(json['dificuldade'] as String),
    recuperacao: Recuperacao.values.byName(json['recuperacao'] as String),
    dorNova: json['dorNova'] as bool? ?? false,
    regiaoDorNova: json['regiaoDorNova'] as String?,
    notaDiferenca: json['notaDiferenca'] as bool? ?? false,
    objetivoMudou: json['objetivoMudou'] as bool? ?? false,
    pesoKg: (json['pesoKg'] as num?)?.toDouble(),
    cinturaCm: (json['cinturaCm'] as num?)?.toDouble(),
    quadrilCm: (json['quadrilCm'] as num?)?.toDouble(),
    bracoCm: (json['bracoCm'] as num?)?.toDouble(),
    coxaCm: (json['coxaCm'] as num?)?.toDouble(),
  );
}
