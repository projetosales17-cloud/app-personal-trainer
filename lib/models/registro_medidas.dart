/// Um registro de medidas corporais na timeline de progresso. Todos os
/// campos são opcionais — a usuária pode registrar só as medidas que
/// quiser em cada ocasião.
class RegistroMedidas {
  const RegistroMedidas({
    required this.data,
    this.cinturaCm,
    this.quadrilCm,
    this.bracoCm,
    this.coxaCm,
  });

  final DateTime data;
  final double? cinturaCm;
  final double? quadrilCm;
  final double? bracoCm;
  final double? coxaCm;

  bool get vazio =>
      cinturaCm == null && quadrilCm == null && bracoCm == null && coxaCm == null;

  Map<String, dynamic> toJson() => {
    'data': data.toIso8601String(),
    'cinturaCm': cinturaCm,
    'quadrilCm': quadrilCm,
    'bracoCm': bracoCm,
    'coxaCm': coxaCm,
  };

  factory RegistroMedidas.fromJson(Map<String, dynamic> json) => RegistroMedidas(
    data: DateTime.parse(json['data'] as String),
    cinturaCm: (json['cinturaCm'] as num?)?.toDouble(),
    quadrilCm: (json['quadrilCm'] as num?)?.toDouble(),
    bracoCm: (json['bracoCm'] as num?)?.toDouble(),
    coxaCm: (json['coxaCm'] as num?)?.toDouble(),
  );
}
