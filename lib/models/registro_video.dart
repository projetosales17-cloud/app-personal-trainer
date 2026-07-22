/// Um registro de vídeo curto de progresso. O arquivo em si fica salvo
/// localmente no aparelho (sem custo de nuvem, ver briefing do produto) —
/// este modelo guarda a data, o caminho do arquivo e, quando a geração
/// funciona (ver gerador_miniatura_video.dart), o caminho de uma miniatura
/// JPEG gerada a partir do vídeo.
class RegistroVideo {
  const RegistroVideo({required this.data, required this.caminhoArquivo, this.caminhoMiniatura});

  final DateTime data;
  final String caminhoArquivo;
  final String? caminhoMiniatura;

  Map<String, dynamic> toJson() => {
    'data': data.toIso8601String(),
    'caminhoArquivo': caminhoArquivo,
    'caminhoMiniatura': caminhoMiniatura,
  };

  factory RegistroVideo.fromJson(Map<String, dynamic> json) => RegistroVideo(
    data: DateTime.parse(json['data'] as String),
    caminhoArquivo: json['caminhoArquivo'] as String,
    caminhoMiniatura: json['caminhoMiniatura'] as String?,
  );
}
