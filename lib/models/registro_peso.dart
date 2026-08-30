import 'id_registro.dart';

/// Um registro de peso na timeline de progresso.
class RegistroPeso {
  RegistroPeso({String? id, required this.data, required this.pesoKg})
    : id = id ?? gerarIdRegistro();

  final String id;
  final DateTime data;
  final double pesoKg;

  RegistroPeso copyWith({DateTime? data, double? pesoKg}) => RegistroPeso(
    id: id,
    data: data ?? this.data,
    pesoKg: pesoKg ?? this.pesoKg,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'data': data.toIso8601String(),
    'pesoKg': pesoKg,
  };

  factory RegistroPeso.fromJson(Map<String, dynamic> json) => RegistroPeso(
    id: json['id'] as String? ?? json['data'] as String,
    data: DateTime.parse(json['data'] as String),
    pesoKg: (json['pesoKg'] as num).toDouble(),
  );
}
