import 'id_registro.dart';

/// Um registro de medidas corporais na timeline de progresso. Todos os
/// campos são opcionais — a usuária pode registrar só as medidas que
/// quiser em cada ocasião. Campos novos (tórax, antebraço, panturrilha,
/// pescoço) ficam nulos em registros salvos antes deles existirem.
class RegistroMedidas {
  RegistroMedidas({
    String? id,
    required this.data,
    this.pescocoCm,
    this.toraxCm,
    this.cinturaCm,
    this.quadrilCm,
    this.bracoCm,
    this.antebracoCm,
    this.coxaCm,
    this.panturrilhaCm,
  }) : id = id ?? gerarIdRegistro();

  final String id;
  final DateTime data;
  final double? pescocoCm;
  final double? toraxCm;
  final double? cinturaCm;
  final double? quadrilCm;
  final double? bracoCm;
  final double? antebracoCm;
  final double? coxaCm;
  final double? panturrilhaCm;

  /// Todas as medidas na ordem em que aparecem no formulário e no resumo
  /// (de cima para baixo no corpo).
  List<(String, double?)> get todas => [
    ('Cuello', pescocoCm),
    ('Tórax', toraxCm),
    ('Brazo', bracoCm),
    ('Antebrazo', antebracoCm),
    ('Cintura', cinturaCm),
    ('Cadera', quadrilCm),
    ('Muslo', coxaCm),
    ('Pantorrilla', panturrilhaCm),
  ];

  bool get vazio => todas.every((m) => m.$2 == null);

  Map<String, dynamic> toJson() => {
    'id': id,
    'data': data.toIso8601String(),
    'pescocoCm': pescocoCm,
    'toraxCm': toraxCm,
    'cinturaCm': cinturaCm,
    'quadrilCm': quadrilCm,
    'bracoCm': bracoCm,
    'antebracoCm': antebracoCm,
    'coxaCm': coxaCm,
    'panturrilhaCm': panturrilhaCm,
  };

  factory RegistroMedidas.fromJson(Map<String, dynamic> json) => RegistroMedidas(
    id: json['id'] as String? ?? json['data'] as String,
    data: DateTime.parse(json['data'] as String),
    pescocoCm: (json['pescocoCm'] as num?)?.toDouble(),
    toraxCm: (json['toraxCm'] as num?)?.toDouble(),
    cinturaCm: (json['cinturaCm'] as num?)?.toDouble(),
    quadrilCm: (json['quadrilCm'] as num?)?.toDouble(),
    bracoCm: (json['bracoCm'] as num?)?.toDouble(),
    antebracoCm: (json['antebracoCm'] as num?)?.toDouble(),
    coxaCm: (json['coxaCm'] as num?)?.toDouble(),
    panturrilhaCm: (json['panturrilhaCm'] as num?)?.toDouble(),
  );
}
