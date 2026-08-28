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

/// Como executar o treino — séries, repetições e descanso — ajustados ao
/// objetivo principal da anamnese. É a peça que faz cada objetivo entregar
/// um treino de verdade diferente (não só uma seleção de exercícios
/// parecida): quem quer hipertrofia recebe cargas altas e descanso longo,
/// quem quer tonificar recebe mais repetições com descanso curto, etc.
class PrescricaoTreino {
  const PrescricaoTreino({
    required this.series,
    required this.repeticoes,
    required this.descanso,
    required this.estilo,
  });

  /// Ex: "3 a 4 séries".
  final String series;

  /// Ex: "8 a 12 repetições".
  final String repeticoes;

  /// Ex: "60 a 90 segundos entre séries".
  final String descanso;

  /// Frase curta explicando o estilo do treino para esse objetivo.
  final String estilo;
}

/// Ficha de treino gerada a partir da anamnese. Tem validade definida
/// (ver briefing do produto: "ficha com validade + alertas de troca").
class FichaTreino {
  const FichaTreino({
    required this.dias,
    required this.geradaEm,
    required this.validaAte,
    this.prescricao,
  });

  final List<DiaDeTreino> dias;
  final DateTime geradaEm;
  final DateTime validaAte;

  /// Séries/repetições/descanso sugeridos para o objetivo. `null` só em
  /// fichas montadas à mão (ex: testes) — o gerador sempre preenche.
  final PrescricaoTreino? prescricao;

  bool get expirada => DateTime.now().isAfter(validaAte);

  /// Datas sugeridas de calendário para um dia da ficha, repetidas
  /// semanalmente até `validaAte`.
  ///
  /// Se [diasDaSemana] for informado (um dia da semana — 1 = segunda ... 7 =
  /// domingo, ver `DateTime.weekday` — por posição em `dias`, mesmo
  /// tamanho de `dias`), usa o dia da semana escolhido pela usuária para
  /// esse dia da ficha. Caso contrário, cai na distribuição automática
  /// aproximada a partir de `geradaEm` (ver briefing do produto).
  List<DateTime> datasPara(DiaDeTreino dia, {List<int>? diasDaSemana}) {
    final indice = dias.indexOf(dia);
    if (indice == -1) return const [];

    final DateTime primeiraData;
    if (diasDaSemana != null && diasDaSemana.length == dias.length) {
      final diaBase = DateTime(geradaEm.year, geradaEm.month, geradaEm.day);
      final diferenca = (diasDaSemana[indice] - diaBase.weekday) % 7;
      primeiraData = diaBase.add(Duration(days: diferenca));
    } else {
      final intervaloDias = 7 / dias.length;
      final inicio = geradaEm.add(Duration(days: (indice * intervaloDias).round()));
      primeiraData = DateTime(inicio.year, inicio.month, inicio.day);
    }

    final datas = <DateTime>[];
    var dataAtual = primeiraData;
    while (!dataAtual.isAfter(validaAte)) {
      datas.add(dataAtual);
      dataAtual = dataAtual.add(const Duration(days: 7));
    }
    return datas;
  }
}
