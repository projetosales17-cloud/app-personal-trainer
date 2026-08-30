import 'id_registro.dart';

/// Um registro de medidas corporais na timeline de progresso. Todos os
/// campos são opcionais — a usuária pode registrar só as medidas que
/// quiser em cada ocasião.
class RegistroMedidas {
  RegistroMedidas({
    String? id,
    required this.data,
    this.cinturaCm,
    this.quadrilCm,
    this.bracoCm,
    this.coxaCm,
  }) : id = id ?? gerarIdRegistro();

  final String id;
  final DateTime data;
  final double? cinturaCm;
  final double? quadrilCm;
  final double? bracoCm;
  final double? coxaCm;

  bool get vazio =>
      cinturaCm == null && quadrilCm == null && bracoCm == null && coxaCm == null;

  RegistroMedidas copyWith({
    DateTime? data,
    double? cinturaCm,
    double? quadrilCm,
    double? bracoCm,
    double? coxaCm,
  }) => RegistroMedidas(
    id: id,
    data: data ?? this.data,
    cinturaCm: cinturaCm ?? this.cinturaCm,
    quadrilCm: quadrilCm ?? this.quadrilCm,
    bracoCm: bracoCm ?? this.bracoCm,
    coxaCm: coxaCm ?? this.coxaCm,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'data': data.toIso8601String(),
    'cinturaCm': cinturaCm,
    'quadrilCm': quadrilCm,
    'bracoCm': bracoCm,
    'coxaCm': coxaCm,
  };

  factory RegistroMedidas.fromJson(Map<String, dynamic> json) => RegistroMedidas(
    id: json['id'] as String? ?? json['data'] as String,
    data: DateTime.parse(json['data'] as String),
    cinturaCm: (json['cinturaCm'] as num?)?.toDouble(),
    quadrilCm: (json['quadrilCm'] as num?)?.toDouble(),
    bracoCm: (json['bracoCm'] as num?)?.toDouble(),
    coxaCm: (json['coxaCm'] as num?)?.toDouble(),
  );
}
