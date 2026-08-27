import '../saude/ciclo_hormonal.dart';
import '../saude/sexo.dart';

export '../saude/ciclo_hormonal.dart' show FaseCiclo;
export '../saude/sexo.dart' show Sexo;

/// Objetivo principal escolhido na anamnese. A ordem aqui é a ordem em que
/// aparecem na tela de onboarding. Os nomes internos (`emagrecimento`,
/// `tonificacao`, ...) não podem mudar — anamneses salvas guardam o `.name`
/// e quebrariam ao recarregar.
enum Objetivo {
  emagrecimento,
  recomposicao,
  tonificacao,
  gluteoPernas,
  hipertrofia,
  performanceAtletica,
  voltarATreinar,
  saudeGeral,
  menopausa,
  terceiraIdade,
}

extension ObjetivoLabel on Objetivo {
  String get label => switch (this) {
    Objetivo.emagrecimento => 'Emagrecer e perder medidas',
    Objetivo.recomposicao => 'Perder gordura e ganhar músculo ao mesmo tempo',
    Objetivo.tonificacao => 'Definir e deixar o corpo tonificado',
    Objetivo.gluteoPernas => 'Foco em glúteo e pernas',
    Objetivo.hipertrofia => 'Ganhar massa muscular',
    Objetivo.performanceAtletica => 'Performance atlética',
    Objetivo.voltarATreinar => 'Voltar a treinar / criar o hábito',
    Objetivo.saudeGeral => 'Saúde e disposição no dia a dia',
    Objetivo.menopausa => 'Saúde na menopausa',
    Objetivo.terceiraIdade =>
      'Terceira idade: mobilidade, equilíbrio e prevenção de quedas',
  };

  /// Descrição curta mostrada abaixo do rótulo na tela de objetivos, para
  /// ajudar a usuária a se identificar com o perfil certo.
  String get descricao => switch (this) {
    Objetivo.emagrecimento =>
      'Reduzir o percentual de gordura e as medidas, com foco no gasto calórico.',
    Objetivo.recomposicao =>
      'Baixar gordura e ganhar um pouco de músculo ao mesmo tempo — ideal se você já está perto do seu peso.',
    Objetivo.tonificacao =>
      'Deixar o corpo mais firme e definido, sem necessariamente aumentar muito de tamanho.',
    Objetivo.gluteoPernas =>
      'Priorizar o desenvolvimento de glúteo e pernas, com mais volume nesses grupos.',
    Objetivo.hipertrofia =>
      'Aumentar o tamanho e o volume muscular com cargas mais exigentes.',
    Objetivo.performanceAtletica =>
      'Ganhar força e potência para render melhor num esporte ou teste físico.',
    Objetivo.voltarATreinar =>
      'Retomar o exercício com calma e criar constância, sem sobrecarregar o corpo.',
    Objetivo.saudeGeral =>
      'Se movimentar com regularidade para ter mais energia, dormir melhor e cuidar da saúde.',
    Objetivo.menopausa =>
      'Preservar músculo e massa óssea e controlar o peso durante a menopausa.',
    Objetivo.terceiraIdade =>
      'Manter a autonomia: mobilidade, equilíbrio e prevenção de quedas.',
  };
}

enum LocalTreino { academia, casa }

extension LocalTreinoLabel on LocalTreino {
  String get label => switch (this) {
    LocalTreino.academia => 'Academia',
    LocalTreino.casa => 'Em casa (sem aparelhos)',
  };
}

enum PreferenciaTreino { soMusculacao, soCardio, combinado }

extension PreferenciaTreinoLabel on PreferenciaTreino {
  String get label => switch (this) {
    PreferenciaTreino.soMusculacao => 'Só musculação',
    PreferenciaTreino.soCardio => 'Só cardio',
    PreferenciaTreino.combinado => 'Musculação + cardio',
  };
}

/// Caminho recomendado pelo app para cada objetivo — a usuária pode
/// escolher outra opção, mas o app sempre sugere uma (ver briefing do
/// produto). Hipertrofia recomenda só musculação (cardio em excesso
/// atrapalha o ganho de massa); os demais objetivos se beneficiam de
/// combinar os dois.
extension PreferenciaTreinoRecomendada on Objetivo {
  PreferenciaTreino get preferenciaTreinoRecomendada => switch (this) {
    // Hipertrofia recomenda só musculação (cardio em excesso atrapalha o
    // ganho de massa).
    Objetivo.hipertrofia => PreferenciaTreino.soMusculacao,
    // Todos os demais objetivos se beneficiam de combinar musculação e
    // cardio.
    Objetivo.emagrecimento => PreferenciaTreino.combinado,
    Objetivo.recomposicao => PreferenciaTreino.combinado,
    Objetivo.tonificacao => PreferenciaTreino.combinado,
    Objetivo.gluteoPernas => PreferenciaTreino.combinado,
    Objetivo.performanceAtletica => PreferenciaTreino.combinado,
    Objetivo.voltarATreinar => PreferenciaTreino.combinado,
    Objetivo.saudeGeral => PreferenciaTreino.combinado,
    Objetivo.menopausa => PreferenciaTreino.combinado,
    Objetivo.terceiraIdade => PreferenciaTreino.combinado,
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
    // Nome e apelido deixam o app mais pessoal — a partir da 2ª abertura a
    // usuária é saudada pelo nome. `nome` vazio em anamneses salvas antes
    // desse campo existir.
    this.nome = '',
    this.apelido,
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
    // Idem: antes de existir cardio na ficha, o comportamento era sempre
    // "só musculação".
    this.preferenciaTreino = PreferenciaTreino.soMusculacao,
    // Campo opcional (ver briefing do produto): quando informado, o
    // GeradorFichaTreino bloqueia exercícios de abdômen por um período
    // determinado após o parto, até liberação médica.
    this.dataParto,
    // Campo opcional (ver briefing do produto): quem está na menopausa,
    // pós-bariátrica ou tem ciclo irregular pode deixar cicloMenstrualRegular
    // em false e pular esse ajuste sem penalidade.
    this.cicloMenstrualRegular = true,
    this.dataUltimaMenstruacao,
  });

  final String nome;
  final String? apelido;
  final int idade;
  final double alturaCm;
  final double pesoAtualKg;
  final double? pesoDesejadoKg;

  /// Como o app deve se dirigir à usuária: o apelido, se houver; senão o
  /// primeiro nome. Vazio quando nenhum nome foi informado.
  String get nomeExibicao {
    final apel = apelido?.trim() ?? '';
    if (apel.isNotEmpty) return apel;
    final partes = nome.trim().split(RegExp(r'\s+'));
    return partes.isEmpty ? '' : partes.first;
  }
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
  final PreferenciaTreino preferenciaTreino;
  final DateTime? dataParto;
  final bool cicloMenstrualRegular;
  final DateTime? dataUltimaMenstruacao;

  /// Fase aproximada do ciclo no momento em que for consultada (não fica
  /// congelada na anamnese — muda conforme os dias passam). `null` quando
  /// a usuária não tem ciclo regular ou não informou a data.
  FaseCiclo? get faseCiclo => (cicloMenstrualRegular && dataUltimaMenstruacao != null)
      ? calcularFaseCiclo(dataUltimaMenstruacao!)
      : null;

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'apelido': apelido,
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
    'preferenciaTreino': preferenciaTreino.name,
    'dataParto': dataParto?.toIso8601String(),
    'cicloMenstrualRegular': cicloMenstrualRegular,
    'dataUltimaMenstruacao': dataUltimaMenstruacao?.toIso8601String(),
  };

  factory Anamnese.fromJson(Map<String, dynamic> json) => Anamnese(
    nome: json['nome'] as String? ?? '',
    apelido: json['apelido'] as String?,
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
    preferenciaTreino: PreferenciaTreino.values.byName(
      json['preferenciaTreino'] as String? ?? 'soMusculacao',
    ),
    dataParto: json['dataParto'] != null ? DateTime.parse(json['dataParto'] as String) : null,
    cicloMenstrualRegular: json['cicloMenstrualRegular'] as bool? ?? true,
    dataUltimaMenstruacao: json['dataUltimaMenstruacao'] != null
        ? DateTime.parse(json['dataUltimaMenstruacao'] as String)
        : null,
  );
}
