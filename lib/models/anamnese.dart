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
    Objetivo.emagrecimento => 'Bajar de peso y perder medidas',
    Objetivo.recomposicao => 'Perder grasa y ganar músculo a la vez',
    Objetivo.tonificacao => 'Definir y tonificar el cuerpo',
    Objetivo.gluteoPernas => 'Enfoque en glúteos y piernas',
    Objetivo.hipertrofia => 'Ganar masa muscular',
    Objetivo.performanceAtletica => 'Rendimiento atlético',
    Objetivo.voltarATreinar => 'Volver a entrenar / crear el hábito',
    Objetivo.saudeGeral => 'Salud y energía en el día a día',
    Objetivo.menopausa => 'Salud en la menopausia',
    Objetivo.terceiraIdade =>
      'Adultos mayores: movilidad, equilibrio y prevención de caídas',
  };

  /// Descrição curta mostrada abaixo do rótulo na tela de objetivos, para
  /// ajudar a usuária a se identificar com o perfil certo.
  String get descricao => switch (this) {
    Objetivo.emagrecimento =>
      'Reducir el porcentaje de grasa y las medidas, con foco en el gasto calórico.',
    Objetivo.recomposicao =>
      'Bajar grasa y ganar algo de músculo al mismo tiempo — ideal si estás cerca de tu peso.',
    Objetivo.tonificacao =>
      'Dejar el cuerpo más firme y definido, sin necesariamente aumentar mucho de tamaño.',
    Objetivo.gluteoPernas =>
      'Priorizar el desarrollo de glúteos y piernas, con más volumen en esos grupos.',
    Objetivo.hipertrofia =>
      'Aumentar el tamaño y el volumen muscular con cargas más exigentes.',
    Objetivo.performanceAtletica =>
      'Ganar fuerza y potencia para rendir mejor en un deporte o prueba física.',
    Objetivo.voltarATreinar =>
      'Retomar el ejercicio con calma y crear constancia, sin sobrecargar el cuerpo.',
    Objetivo.saudeGeral =>
      'Moverte con regularidad para tener más energía, dormir mejor y cuidar la salud.',
    Objetivo.menopausa =>
      'Preservar músculo y masa ósea y manejar el peso durante la menopausia.',
    Objetivo.terceiraIdade =>
      'Mantener la autonomía: movilidad, equilibrio y prevención de caídas.',
  };
}

enum LocalTreino { academia, casa }

extension LocalTreinoLabel on LocalTreino {
  String get label => switch (this) {
    LocalTreino.academia => 'Gimnasio',
    LocalTreino.casa => 'En casa (sin aparatos)',
  };
}

enum PreferenciaTreino { soMusculacao, soCardio, combinado }

extension PreferenciaTreinoLabel on PreferenciaTreino {
  String get label => switch (this) {
    PreferenciaTreino.soMusculacao => 'Solo musculación',
    PreferenciaTreino.soCardio => 'Solo cardio',
    PreferenciaTreino.combinado => 'Musculación + cardio',
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
    NivelAtividade.sedentario => 'Sedentaria',
    NivelAtividade.leve => 'Leve',
    NivelAtividade.moderado => 'Moderada',
    NivelAtividade.intenso => 'Intensa',
    NivelAtividade.muitoIntenso => 'Muy intensa',
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
    this.condicaoHormonal = 'Ninguna',
    this.restricoesAlimentares = const [],
    this.lesoesLimitacoes = const [],
    // Grupos musculares que a usuária escolheu NÃO treinar (lesão,
    // recomendação médica ou preferência). Guardados como
    // `GrupoMuscular.name`. O GeradorFichaTreino tira esses grupos da
    // ficha. Vazio em anamneses salvas antes desse campo existir.
    this.gruposEvitar = const [],
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
    // Duração média do ciclo (1º dia de uma menstruação até o 1º dia da
    // próxima). `null` usa o padrão de 28 dias — comportamento de anamneses
    // salvas antes desse campo existir. Deixa a estimativa de fase mais
    // precisa para quem tem ciclo regular mas diferente de 28 dias.
    this.duracaoCicloDias,
  });

  final String nome;
  final String? apelido;
  final int idade;
  final double alturaCm;
  final double pesoAtualKg;
  final double? pesoDesejadoKg;
  final Sexo sexo;

  /// Como o app deve se dirigir à usuária: o apelido, se houver; senão o
  /// primeiro nome. Vazio quando nenhum nome foi informado.
  String get nomeExibicao {
    final apel = apelido?.trim() ?? '';
    if (apel.isNotEmpty) return apel;
    final partes = nome.trim().split(RegExp(r'\s+'));
    return partes.isEmpty ? '' : partes.first;
  }
  final Objetivo objetivoPrincipal;
  final bool cirurgiaBariatrica;
  final String? tipoCirurgiaBariatrica;
  final int? mesesDesdeCirurgia;
  final String condicaoHormonal;
  final List<String> restricoesAlimentares;
  final List<String> lesoesLimitacoes;
  final List<String> gruposEvitar;
  final NivelAtividade nivelAtividade;
  final int frequenciaSemanalDias;
  final List<String> regioesPriorizadas;
  final LocalTreino localTreino;
  final PreferenciaTreino preferenciaTreino;
  final DateTime? dataParto;
  final bool cicloMenstrualRegular;
  final DateTime? dataUltimaMenstruacao;
  final int? duracaoCicloDias;

  /// Fase aproximada do ciclo no momento em que for consultada (não fica
  /// congelada na anamnese — muda conforme os dias passam). `null` quando
  /// a usuária não tem ciclo regular ou não informou a data. Usa a duração
  /// de ciclo informada, ou 28 dias quando não informada.
  FaseCiclo? get faseCiclo => (cicloMenstrualRegular && dataUltimaMenstruacao != null)
      ? calcularFaseCiclo(
          dataUltimaMenstruacao!,
          duracaoCiclo: duracaoCicloDias ?? duracaoCicloDiasPadrao,
        )
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
    'gruposEvitar': gruposEvitar,
    'nivelAtividade': nivelAtividade.name,
    'frequenciaSemanalDias': frequenciaSemanalDias,
    'regioesPriorizadas': regioesPriorizadas,
    'localTreino': localTreino.name,
    'preferenciaTreino': preferenciaTreino.name,
    'dataParto': dataParto?.toIso8601String(),
    'cicloMenstrualRegular': cicloMenstrualRegular,
    'dataUltimaMenstruacao': dataUltimaMenstruacao?.toIso8601String(),
    'duracaoCicloDias': duracaoCicloDias,
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
    condicaoHormonal: json['condicaoHormonal'] as String? ?? 'Ninguna',
    restricoesAlimentares:
        (json['restricoesAlimentares'] as List?)?.cast<String>() ?? const [],
    lesoesLimitacoes:
        (json['lesoesLimitacoes'] as List?)?.cast<String>() ?? const [],
    gruposEvitar: (json['gruposEvitar'] as List?)?.cast<String>() ?? const [],
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
    duracaoCicloDias: (json['duracaoCicloDias'] as num?)?.toInt(),
  );
}
