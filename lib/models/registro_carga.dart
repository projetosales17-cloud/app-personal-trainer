import 'id_registro.dart';

/// Um registro de carga de um exercício específico, na timeline de
/// histórico de treino.
class RegistroCarga {
  RegistroCarga({
    String? id,
    required this.exercicioId,
    required this.data,
    required this.pesoKg,
    required this.series,
    required this.repeticoes,
  }) : id = id ?? gerarIdRegistro();

  final String id;
  final String exercicioId;
  final DateTime data;
  final double pesoKg;
  final int series;
  final int repeticoes;

  RegistroCarga copyWith({
    DateTime? data,
    double? pesoKg,
    int? series,
    int? repeticoes,
  }) => RegistroCarga(
    id: id,
    exercicioId: exercicioId,
    data: data ?? this.data,
    pesoKg: pesoKg ?? this.pesoKg,
    series: series ?? this.series,
    repeticoes: repeticoes ?? this.repeticoes,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'exercicioId': exercicioId,
    'data': data.toIso8601String(),
    'pesoKg': pesoKg,
    'series': series,
    'repeticoes': repeticoes,
  };

  factory RegistroCarga.fromJson(Map<String, dynamic> json) => RegistroCarga(
    id: json['id'] as String? ?? json['data'] as String,
    exercicioId: json['exercicioId'] as String,
    data: DateTime.parse(json['data'] as String),
    pesoKg: (json['pesoKg'] as num).toDouble(),
    series: json['series'] as int,
    repeticoes: json['repeticoes'] as int,
  );
}
