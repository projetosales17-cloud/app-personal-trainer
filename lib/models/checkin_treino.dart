/// Registro de que a usuária concluiu o treino de uma data específica da
/// ficha (ver `FichaTreino.datasPara`). A ausência de um registro para uma
/// data já passada é o que o motor de aderência interpreta como "treino
/// pulado" — não existe um registro explícito de "pulei".
class CheckinTreino {
  const CheckinTreino({required this.data, required this.diaFicha});

  final DateTime data;
  final int diaFicha;

  Map<String, dynamic> toJson() => {
    'data': data.toIso8601String(),
    'diaFicha': diaFicha,
  };

  factory CheckinTreino.fromJson(Map<String, dynamic> json) => CheckinTreino(
    data: DateTime.parse(json['data'] as String),
    diaFicha: json['diaFicha'] as int,
  );
}
