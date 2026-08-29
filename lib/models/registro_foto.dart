import 'dart:convert';
import 'dart:typed_data';

/// Ângulo sugerido da foto de progresso. Marcar o ângulo deixa a
/// comparação antes/depois honesta (frente vs frente, e não frente vs
/// costas). `livre` é o padrão e não tem limite de quantidade.
enum PoseFoto { frente, lado, costas, livre }

extension PoseFotoLabel on PoseFoto {
  String get label => switch (this) {
    PoseFoto.frente => 'Frente',
    PoseFoto.lado => 'Lateral',
    PoseFoto.costas => 'Espalda',
    PoseFoto.livre => 'Libre',
  };
}

/// Um registro de foto de progresso. A imagem é guardada como data URI
/// base64 (`data:image/jpeg;base64,...`) — assim vale tanto na web quanto
/// no celular e sincroniza entre aparelhos pelo Firestore
/// (`usuarios/{uid}/fotos_progresso/{id}`), sem depender de Storage.
class RegistroFoto {
  const RegistroFoto({
    required this.id,
    required this.data,
    required this.dataUri,
    this.pose = PoseFoto.livre,
  });

  /// Id do documento no Firestore. Fotos criadas offline começam com
  /// `local_` até subirem.
  final String id;
  final DateTime data;
  final String dataUri;
  final PoseFoto pose;

  /// Bytes decodificados da imagem, para `Image.memory`.
  Uint8List get bytes {
    final virgula = dataUri.indexOf(',');
    return base64Decode(virgula == -1 ? dataUri : dataUri.substring(virgula + 1));
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'data': data.toIso8601String(),
    'dataUri': dataUri,
    'pose': pose.name,
  };

  factory RegistroFoto.fromJson(Map<String, dynamic> json) => RegistroFoto(
    id: json['id'] as String? ?? 'local_${json['data']}',
    data: DateTime.parse(json['data'] as String),
    dataUri: json['dataUri'] as String,
    pose: _poseDe(json['pose'] as String?),
  );

  static PoseFoto _poseDe(String? nome) {
    if (nome == null) return PoseFoto.livre;
    return PoseFoto.values.firstWhere((p) => p.name == nome, orElse: () => PoseFoto.livre);
  }
}
