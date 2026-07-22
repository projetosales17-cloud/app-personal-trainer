import 'atividade_cardio.dart';
import 'exercicio.dart';

class DiaDeTreino {
  const DiaDeTreino({
    required this.dia,
    required this.gruposMusculares,
    required this.exercicios,
    this.atividadesCardio = const [],
  });

  final int dia;
  final List<GrupoMuscular> gruposMusculares;
  final List<Exercicio> exercicios;
  final List<AtividadeCardio> atividadesCardio;
}

/// Ficha de treino gerada a partir da anamnese. Tem validade definida
/// (ver briefing do produto: "ficha com validade + alertas de troca").
class FichaTreino {
  const FichaTreino({
    required this.dias,
    required this.geradaEm,
    required this.validaAte,
  });

  final List<DiaDeTreino> dias;
  final DateTime geradaEm;
  final DateTime validaAte;

  bool get expirada => DateTime.now().isAfter(validaAte);

  /// Datas sugeridas de calendário para um dia da ficha, distribuídas ao
  /// longo da semana (a partir de `geradaEm`) e repetidas semanalmente até
  /// `validaAte`. É uma distribuição aproximada, não um agendamento exato
  /// por dia da semana escolhido pela usuária (ver briefing do produto).
  List<DateTime> datasPara(DiaDeTreino dia) {
    final indice = dias.indexOf(dia);
    if (indice == -1) return const [];

    final intervaloDias = 7 / dias.length;
    final inicio = geradaEm.add(Duration(days: (indice * intervaloDias).round()));
    final primeiraData = DateTime(inicio.year, inicio.month, inicio.day);

    final datas = <DateTime>[];
    var dataAtual = primeiraData;
    while (!dataAtual.isAfter(validaAte)) {
      datas.add(dataAtual);
      dataAtual = dataAtual.add(const Duration(days: 7));
    }
    return datas;
  }
}
