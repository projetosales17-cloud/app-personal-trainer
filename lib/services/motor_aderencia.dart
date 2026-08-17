/// Resultado da avaliação de aderência (ver `MotorAderencia`).
class ResultadoAderencia {
  const ResultadoAderencia({
    required this.treinosPuladosConsecutivos,
    required this.emAlerta,
    this.mensagem,
  });

  final int treinosPuladosConsecutivos;
  final bool emAlerta;
  final String? mensagem;
}

/// Motor de regras local (sem IA, sem custo por chamada) que detecta
/// quando a usuária vem pulando treinos consecutivos — comparando os dias
/// da semana escolhidos para treinar (ver `PreferenciasRepository`) com o
/// histórico de check-ins (ver `CheckinTreinoRepository`). Quando o
/// limite é atingido, sinaliza para o `GeradorFichaTreino` reduzir o
/// volume da próxima ficha (sessão de "retomada") e mostra uma mensagem
/// pré-escrita — sem nenhuma regra de IA por trás.
class MotorAderencia {
  static const limiteAlerta = 2;
  static const _janelaDatasEsperadas = 6;

  static const _mensagemAlerta =
      'Notamos que te saltaste los últimos entrenamientos — no pasa nada. '
      'Preparamos una rutina con volumen reducido para facilitar tu '
      'regreso hoy.';

  /// Sem dias da semana escolhidos, não há como saber com confiança quais
  /// datas eram esperadas — retorna neutro (sem alerta) nesse caso.
  ResultadoAderencia avaliar({
    required List<int>? diasDaSemanaEsperados,
    required List<DateTime> datasCheckin,
    DateTime? referencia,
  }) {
    if (diasDaSemanaEsperados == null || diasDaSemanaEsperados.isEmpty) {
      return const ResultadoAderencia(treinosPuladosConsecutivos: 0, emAlerta: false);
    }

    final hoje = _normalizar(referencia ?? DateTime.now());
    final checkinsNormalizados = datasCheckin.map(_normalizar).toSet();
    final datasEsperadas = _ultimasDatasEsperadas(diasDaSemanaEsperados, hoje);

    var consecutivos = 0;
    for (final data in datasEsperadas.reversed) {
      if (checkinsNormalizados.contains(data)) break;
      consecutivos++;
    }

    final emAlerta = consecutivos >= limiteAlerta;
    return ResultadoAderencia(
      treinosPuladosConsecutivos: consecutivos,
      emAlerta: emAlerta,
      mensagem: emAlerta ? _mensagemAlerta : null,
    );
  }

  /// As últimas [_janelaDatasEsperadas] datas (estritamente antes de
  /// [hoje]) em que a usuária deveria ter treinado, da mais antiga pra
  /// mais recente.
  List<DateTime> _ultimasDatasEsperadas(List<int> diasDaSemana, DateTime hoje) {
    final datas = <DateTime>[];
    var cursor = hoje.subtract(const Duration(days: 1));
    var voltas = 0;
    while (datas.length < _janelaDatasEsperadas && voltas < 60) {
      if (diasDaSemana.contains(cursor.weekday)) {
        datas.add(cursor);
      }
      cursor = cursor.subtract(const Duration(days: 1));
      voltas++;
    }
    return datas.reversed.toList();
  }

  DateTime _normalizar(DateTime data) => DateTime(data.year, data.month, data.day);
}
