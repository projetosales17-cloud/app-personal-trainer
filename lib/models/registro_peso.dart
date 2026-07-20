/// Um registro de peso na timeline de progresso. Medidas, fotos/vídeos e
/// gráficos ainda não foram implementados (ver briefing do produto).
class RegistroPeso {
  const RegistroPeso({required this.data, required this.pesoKg});

  final DateTime data;
  final double pesoKg;

  Map<String, dynamic> toJson() => {
    'data': data.toIso8601String(),
    'pesoKg': pesoKg,
  };

  factory RegistroPeso.fromJson(Map<String, dynamic> json) => RegistroPeso(
    data: DateTime.parse(json['data'] as String),
    pesoKg: (json['pesoKg'] as num).toDouble(),
  );
}
