/// Um registro simples do diário alimentar — sem contagem de calorias na v1
/// (ver briefing do produto).
class RegistroDiario {
  const RegistroDiario({required this.data, required this.refeicao, required this.descricao});

  final DateTime data;
  final String refeicao;
  final String descricao;

  Map<String, dynamic> toJson() => {
    'data': data.toIso8601String(),
    'refeicao': refeicao,
    'descricao': descricao,
  };

  factory RegistroDiario.fromJson(Map<String, dynamic> json) => RegistroDiario(
    data: DateTime.parse(json['data'] as String),
    refeicao: json['refeicao'] as String,
    descricao: json['descricao'] as String,
  );
}
