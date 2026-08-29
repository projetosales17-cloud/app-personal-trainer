import 'dart:convert';
import 'dart:typed_data';

/// Um registro de foto de progresso. A imagem é guardada como data URI
/// base64 (`data:image/jpeg;base64,...`) — assim vale tanto na web quanto
/// no celular e sincroniza entre aparelhos pelo Firestore
/// (`usuarios/{uid}/fotos_progresso/{id}`), sem depender de Storage.
class RegistroFoto {
  const RegistroFoto({
    required this.id,
    required this.data,
    required this.dataUri,
  });

  /// Id do documento no Firestore. Fotos criadas offline começam com
  /// `local_` até subirem.
  final String id;
  final DateTime data;
  final String dataUri;

  /// Bytes decodificados da imagem, para `Image.memory`.
  Uint8List get bytes {
    final virgula = dataUri.indexOf(',');
    return base64Decode(virgula == -1 ? dataUri : dataUri.substring(virgula + 1));
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'data': data.toIso8601String(),
    'dataUri': dataUri,
  };

  factory RegistroFoto.fromJson(Map<String, dynamic> json) => RegistroFoto(
    id: json['id'] as String? ?? 'local_${json['data']}',
    data: DateTime.parse(json['data'] as String),
    dataUri: json['dataUri'] as String,
  );
}
