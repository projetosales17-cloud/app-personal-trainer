/// Um registro de carga de um exercício específico, na timeline de
/// histórico de treino. Cronômetro de descanso, calendário e gráfico de
/// evolução ainda não foram implementados (ver briefing do produto).
class RegistroCarga {
  const RegistroCarga({
    required this.exercicioId,
    required this.data,
    required this.pesoKg,
    required this.series,
    required this.repeticoes,
  });

  final String exercicioId;
  final DateTime data;
  final double pesoKg;
  final int series;
  final int repeticoes;

  Map<String, dynamic> toJson() => {
    'exercicioId': exercicioId,
    'data': data.toIso8601String(),
    'pesoKg': pesoKg,
    'series': series,
    'repeticoes': repeticoes,
  };

  factory RegistroCarga.fromJson(Map<String, dynamic> json) => RegistroCarga(
    exercicioId: json['exercicioId'] as String,
    data: DateTime.parse(json['data'] as String),
    pesoKg: (json['pesoKg'] as num).toDouble(),
    series: json['series'] as int,
    repeticoes: json['repeticoes'] as int,
  );
}
