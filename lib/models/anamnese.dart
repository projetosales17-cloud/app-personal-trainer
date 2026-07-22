import '../saude/sexo.dart';

export '../saude/sexo.dart' show Sexo;

enum Objetivo {
  emagrecimento,
  tonificacao,
  hipertrofia,
  performanceAtletica,
  saudeGeral,
}

extension ObjetivoLabel on Objetivo {
  String get label => switch (this) {
    Objetivo.emagrecimento => 'Emagrecimento',
    Objetivo.tonificacao => 'Tonificação',
    Objetivo.hipertrofia => 'Hipertrofia',
    Objetivo.performanceAtletica => 'Performance atlética',
    Objetivo.saudeGeral => 'Saúde geral (ex: menopausa)',
  };
}

enum LocalTreino { academia, casa }

extension LocalTreinoLabel on LocalTreino {
  String get label => switch (this) {
    LocalTreino.academia => 'Academia',
    LocalTreino.casa => 'Em casa (sem aparelhos)',
  };
}

enum NivelAtividade { sedentario, leve, moderado, intenso, muitoIntenso }

extension NivelAtividadeLabel on NivelAtividade {
  String get label => switch (this) {
    NivelAtividade.sedentario => 'Sedentário',
    NivelAtividade.leve => 'Leve',
    NivelAtividade.moderado => 'Moderado',
    NivelAtividade.intenso => 'Intenso',
    NivelAtividade.muitoIntenso => 'Muito intenso',
  };
}

/// Dados coletados na anamnese de onboarding. Usados para gerar o plano
/// inicial de treino e alimentação.
class Anamnese {
  const Anamnese({
    required this.idade,
    required this.alturaCm,
    required this.pesoAtualKg,
    this.pesoDesejadoKg,
    // O app é voltado ao público feminino (ver briefing do produto); não há
    // ainda uma etapa de onboarding perguntando o sexo explicitamente, então
    // assumimos feminino por padrão. Necessário para a fórmula de TMB.
    this.sexo = Sexo.feminino,
    required this.objetivoPrincipal,
    this.cirurgiaBariatrica = false,
    this.tipoCirurgiaBariatrica,
    this.mesesDesdeCirurgia,
    this.condicaoHormonal = 'Nenhuma',
    this.restricoesAlimentares = const [],
    this.lesoesLimitacoes = const [],
    required this.nivelAtividade,
    required this.frequenciaSemanalDias,
    this.regioesPriorizadas = const [],
    // Anamneses salvas antes desse campo existir (ver fromJson) assumem
    // academia, que era o único modo suportado pela geração de ficha até então.
    this.localTreino = LocalTreino.academia,
  });

  final int idade;
  final double alturaCm;
  final double pesoAtualKg;
  final double? pesoDesejadoKg;
  final Sexo sexo;
  final Objetivo objetivoPrincipal;
  final bool cirurgiaBariatrica;
  final String? tipoCirurgiaBariatrica;
  final int? mesesDesdeCirurgia;
  final String condicaoHormonal;
  final List<String> restricoesAlimentares;
  final List<String> lesoesLimitacoes;
  final NivelAtividade nivelAtividade;
  final int frequenciaSemanalDias;
  final List<String> regioesPriorizadas;
  final LocalTreino localTreino;

  Map<String, dynamic> toJson() => {
    'idade': idade,
    'alturaCm': alturaCm,
    'pesoAtualKg': pesoAtualKg,
    'pesoDesejadoKg': pesoDesejadoKg,
    'sexo': sexo.name,
    'objetivoPrincipal': objetivoPrincipal.name,
    'cirurgiaBariatrica': cirurgiaBariatrica,
    'tipoCirurgiaBariatrica': tipoCirurgiaBariatrica,
    'mesesDesdeCirurgia': mesesDesdeCirurgia,
    'condicaoHormonal': condicaoHormonal,
    'restricoesAlimentares': restricoesAlimentares,
    'lesoesLimitacoes': lesoesLimitacoes,
    'nivelAtividade': nivelAtividade.name,
    'frequenciaSemanalDias': frequenciaSemanalDias,
    'regioesPriorizadas': regioesPriorizadas,
    'localTreino': localTreino.name,
  };

  factory Anamnese.fromJson(Map<String, dynamic> json) => Anamnese(
    idade: json['idade'] as int,
    alturaCm: (json['alturaCm'] as num).toDouble(),
    pesoAtualKg: (json['pesoAtualKg'] as num).toDouble(),
    pesoDesejadoKg: (json['pesoDesejadoKg'] as num?)?.toDouble(),
    sexo: Sexo.values.byName(json['sexo'] as String? ?? 'feminino'),
    objetivoPrincipal: Objetivo.values.byName(json['objetivoPrincipal'] as String),
    cirurgiaBariatrica: json['cirurgiaBariatrica'] as bool? ?? false,
    tipoCirurgiaBariatrica: json['tipoCirurgiaBariatrica'] as String?,
    mesesDesdeCirurgia: json['mesesDesdeCirurgia'] as int?,
    condicaoHormonal: json['condicaoHormonal'] as String? ?? 'Nenhuma',
    restricoesAlimentares:
        (json['restricoesAlimentares'] as List?)?.cast<String>() ?? const [],
    lesoesLimitacoes:
        (json['lesoesLimitacoes'] as List?)?.cast<String>() ?? const [],
    nivelAtividade: NivelAtividade.values.byName(json['nivelAtividade'] as String),
    frequenciaSemanalDias: json['frequenciaSemanalDias'] as int,
    regioesPriorizadas:
        (json['regioesPriorizadas'] as List?)?.cast<String>() ?? const [],
    localTreino: LocalTreino.values.byName(json['localTreino'] as String? ?? 'academia'),
  );
}
