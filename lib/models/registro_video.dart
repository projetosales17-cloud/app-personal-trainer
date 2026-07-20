/// Um registro de vídeo curto de progresso. O arquivo em si fica salvo
/// localmente no aparelho (sem custo de nuvem, ver briefing do produto) —
/// este modelo só guarda a data e o caminho do arquivo.
class RegistroVideo {
  const RegistroVideo({required this.data, required this.caminhoArquivo});

  final DateTime data;
  final String caminhoArquivo;

  Map<String, dynamic> toJson() => {
    'data': data.toIso8601String(),
    'caminhoArquivo': caminhoArquivo,
  };

  factory RegistroVideo.fromJson(Map<String, dynamic> json) => RegistroVideo(
    data: DateTime.parse(json['data'] as String),
    caminhoArquivo: json['caminhoArquivo'] as String,
  );
}
