import 'id_registro.dart';

/// Um registro de vídeo curto de progresso. O arquivo em si fica salvo
/// localmente no aparelho (sem custo de nuvem, ver briefing do produto) —
/// este modelo guarda a data, o caminho do arquivo e, quando a geração
/// funciona (ver gerador_miniatura_video.dart), o caminho de uma miniatura
/// JPEG gerada a partir do vídeo.
class RegistroVideo {
  RegistroVideo({
    String? id,
    required this.data,
    required this.caminhoArquivo,
    this.caminhoMiniatura,
  }) : id = id ?? gerarIdRegistro();

  final String id;
  final DateTime data;
  final String caminhoArquivo;
  final String? caminhoMiniatura;

  Map<String, dynamic> toJson() => {
    'id': id,
    'data': data.toIso8601String(),
    'caminhoArquivo': caminhoArquivo,
    'caminhoMiniatura': caminhoMiniatura,
  };

  factory RegistroVideo.fromJson(Map<String, dynamic> json) => RegistroVideo(
    id: json['id'] as String? ?? json['data'] as String,
    data: DateTime.parse(json['data'] as String),
    caminhoArquivo: json['caminhoArquivo'] as String,
    caminhoMiniatura: json['caminhoMiniatura'] as String?,
  );
}
