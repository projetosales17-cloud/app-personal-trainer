import 'checkin_progresso.dart';
import 'exercicio.dart';

/// Estado do programa de treino de longo prazo (pelo menos 2 anos). O
/// programa avança em blocos de ~6 semanas; ao fim de cada bloco a usuária
/// preenche um check-in de progresso (ver `CheckinProgresso`) e o app
/// decide a estratégia da próxima ficha (ver `EstrategiaBloco`).
class ProgramaTreino {
  const ProgramaTreino({
    required this.iniciadoEm,
    required this.blocoAtual,
    required this.blocoIniciadoEm,
    required this.nivelLiberado,
    this.checkins = const [],
  });

  /// Data da primeira ficha gerada — nunca é resetada (só num "recomeçar
  /// programa" explícito).
  final DateTime iniciadoEm;

  /// Número do bloco atual, começando em 1.
  final int blocoAtual;

  /// Quando o bloco atual começou (usado para saber quando pedir o
  /// check-in).
  final DateTime blocoIniciadoEm;

  /// Nível de exercício mais alto já liberado. Sobe via check-in quando a
  /// usuária relata que o treino está fácil e ela está bem recuperada.
  final NivelExercicio nivelLiberado;

  final List<CheckinProgresso> checkins;

  static const duracaoBlocoDias = 42;
  static const duracaoTotalDias = 730;

  CheckinProgresso? get ultimoCheckin => checkins.isEmpty ? null : checkins.last;

  int _diasNoBloco([DateTime? agora]) =>
      (agora ?? DateTime.now()).difference(blocoIniciadoEm).inDays;

  /// True quando o bloco atual já durou o suficiente para pedir o check-in
  /// de progresso.
  bool precisaCheckin([DateTime? agora]) => _diasNoBloco(agora) >= duracaoBlocoDias;

  int diasParaProximoCheckin([DateTime? agora]) =>
      (duracaoBlocoDias - _diasNoBloco(agora)).clamp(0, duracaoBlocoDias);

  int semanasParaProximoCheckin([DateTime? agora]) =>
      (diasParaProximoCheckin(agora) / 7).ceil();

  /// Semana do programa (1-based).
  int semanaAtual([DateTime? agora]) =>
      ((agora ?? DateTime.now()).difference(iniciadoEm).inDays / 7).floor() + 1;

  ProgramaTreino copyWith({
    int? blocoAtual,
    DateTime? blocoIniciadoEm,
    NivelExercicio? nivelLiberado,
    List<CheckinProgresso>? checkins,
  }) => ProgramaTreino(
    iniciadoEm: iniciadoEm,
    blocoAtual: blocoAtual ?? this.blocoAtual,
    blocoIniciadoEm: blocoIniciadoEm ?? this.blocoIniciadoEm,
    nivelLiberado: nivelLiberado ?? this.nivelLiberado,
    checkins: checkins ?? this.checkins,
  );

  Map<String, dynamic> toJson() => {
    'iniciadoEm': iniciadoEm.toIso8601String(),
    'blocoAtual': blocoAtual,
    'blocoIniciadoEm': blocoIniciadoEm.toIso8601String(),
    'nivelLiberado': nivelLiberado.name,
    'checkins': [for (final c in checkins) c.toJson()],
  };

  factory ProgramaTreino.fromJson(Map<String, dynamic> json) => ProgramaTreino(
    iniciadoEm: DateTime.parse(json['iniciadoEm'] as String),
    blocoAtual: json['blocoAtual'] as int? ?? 1,
    blocoIniciadoEm: DateTime.parse(
      (json['blocoIniciadoEm'] ?? json['iniciadoEm']) as String,
    ),
    nivelLiberado: NivelExercicio.values.byName(
      json['nivelLiberado'] as String? ?? 'iniciante',
    ),
    checkins: [
      for (final item in (json['checkins'] as List? ?? const []))
        CheckinProgresso.fromJson(item as Map<String, dynamic>),
    ],
  );
}
