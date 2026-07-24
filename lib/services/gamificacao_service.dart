/// Resultado da avaliação de gamificação (ver `GamificacaoService`).
class ResultadoGamificacao {
  const ResultadoGamificacao({
    required this.pontosTotais,
    required this.streakDias,
    required this.metaSemanalBatida,
  });

  final int pontosTotais;
  final int streakDias;
  final bool metaSemanalBatida;
}

/// Gamificação local (sem IA, sem custo por chamada, sem cupom — ver
/// briefing do produto): pontos derivados do histórico de check-ins de
/// treino, sempre recalculados a partir da fonte de verdade (não é um
/// contador incremental, já que um check-in pode ser desmarcado).
///
/// - Sessão completa registrada: pontos por check-in.
/// - Streak: dias esperados consecutivos concluídos até hoje.
/// - Meta semanal batida: todos os dias esperados da semana atual (que já
///   passaram) foram concluídos.
class GamificacaoService {
  static const pontosPorSessao = 10;
  static const pontosPorDiaDeStreak = 5;
  static const pontosPorMetaSemanal = 50;

  /// Marcos de streak que disparam uma notificação de conquista (ver
  /// `NotificadorConquistas`).
  static const marcosStreak = {3, 7, 14, 30};

  ResultadoGamificacao calcular({
    required List<int>? diasDaSemanaEsperados,
    required List<DateTime> datasCheckin,
    DateTime? referencia,
  }) {
    final hoje = _normalizar(referencia ?? DateTime.now());
    final checkins = datasCheckin.map(_normalizar).toSet();

    final semDiasEscolhidos = diasDaSemanaEsperados == null || diasDaSemanaEsperados.isEmpty;
    final streak = semDiasEscolhidos ? 0 : _streakAtual(diasDaSemanaEsperados, checkins, hoje);
    final metaBatida = semDiasEscolhidos
        ? false
        : _metaSemanalBatida(diasDaSemanaEsperados, checkins, hoje);

    final pontosTotais =
        checkins.length * pontosPorSessao +
        streak * pontosPorDiaDeStreak +
        (metaBatida ? pontosPorMetaSemanal : 0);

    return ResultadoGamificacao(
      pontosTotais: pontosTotais,
      streakDias: streak,
      metaSemanalBatida: metaBatida,
    );
  }

  int _streakAtual(List<int> diasDaSemana, Set<DateTime> checkins, DateTime hoje) {
    var streak = 0;
    if (diasDaSemana.contains(hoje.weekday) && checkins.contains(hoje)) {
      streak++;
    }

    var cursor = hoje.subtract(const Duration(days: 1));
    var voltas = 0;
    while (voltas < 400) {
      if (diasDaSemana.contains(cursor.weekday)) {
        if (checkins.contains(cursor)) {
          streak++;
        } else {
          break;
        }
      }
      cursor = cursor.subtract(const Duration(days: 1));
      voltas++;
    }
    return streak;
  }

  /// Considera batida quando todos os dias esperados da semana atual que
  /// já passaram (segunda a hoje) têm check-in — dias futuros da mesma
  /// semana não bloqueiam a meta, pra dar o reforço positivo assim que
  /// possível em vez de só no fim da semana. Precisa de pelo menos um dia
  /// esperado já ocorrido (senão seria "batida" vazia, sem nada feito).
  bool _metaSemanalBatida(List<int> diasDaSemana, Set<DateTime> checkins, DateTime hoje) {
    final segunda = hoje.subtract(Duration(days: hoje.weekday - 1));
    var algumDiaJaPassou = false;
    for (var i = 0; i < 7; i++) {
      final dia = segunda.add(Duration(days: i));
      if (!diasDaSemana.contains(dia.weekday)) continue;
      if (dia.isAfter(hoje)) continue;
      algumDiaJaPassou = true;
      if (!checkins.contains(dia)) return false;
    }
    return algumDiaJaPassou;
  }

  DateTime _normalizar(DateTime data) => DateTime(data.year, data.month, data.day);
}
