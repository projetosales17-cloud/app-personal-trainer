import 'id_registro.dart';

/// Um registro simples do diário alimentar — sem contagem de calorias na v1
/// (ver briefing do produto).
class RegistroDiario {
  RegistroDiario({
    String? id,
    required this.data,
    required this.refeicao,
    required this.descricao,
  }) : id = id ?? gerarIdRegistro();

  final String id;
  final DateTime data;
  final String refeicao;
  final String descricao;

  RegistroDiario copyWith({DateTime? data, String? refeicao, String? descricao}) =>
      RegistroDiario(
        id: id,
        data: data ?? this.data,
        refeicao: refeicao ?? this.refeicao,
        descricao: descricao ?? this.descricao,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'data': data.toIso8601String(),
    'refeicao': refeicao,
    'descricao': descricao,
  };

  factory RegistroDiario.fromJson(Map<String, dynamic> json) => RegistroDiario(
    id: json['id'] as String? ?? json['data'] as String,
    data: DateTime.parse(json['data'] as String),
    refeicao: json['refeicao'] as String,
    descricao: json['descricao'] as String,
  );
}
