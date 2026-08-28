import '../models/registro_carga.dart';

/// Resumo da evolução de carga de um exercício, montado a partir do
/// histórico de [RegistroCarga]. Regra de negócio local, sem IA — só olha
/// o que a usuária registrou (ver briefing do produto).
class EvolucaoCarga {
  const EvolucaoCarga({
    required this.exercicioId,
    required this.pesos,
    required this.pesoInicial,
    required this.pesoAtual,
    required this.primeiroEm,
    required this.ultimoEm,
    required this.totalRegistros,
  });

  final String exercicioId;

  /// Pesos de cada registro, na ordem cronológica — série para o gráfico.
  final List<double> pesos;

  final double pesoInicial;
  final double pesoAtual;
  final DateTime primeiroEm;
  final DateTime ultimoEm;
  final int totalRegistros;

  bool get progrediu => pesoAtual > pesoInicial;
  double get ganhoKg => pesoAtual - pesoInicial;

  /// Ganho percentual arredondado. 0 quando o peso inicial é 0 (exercícios
  /// de peso do corpo) — nesse caso o ganho em kg não faz sentido em %.
  int get ganhoPercentual =>
      pesoInicial > 0 ? ((ganhoKg / pesoInicial) * 100).round() : 0;

  /// Semanas entre o primeiro e o último registro (mínimo 1).
  int get semanas {
    final dias = ultimoEm.difference(primeiroEm).inDays;
    final semanas = (dias / 7).ceil();
    return semanas < 1 ? 1 : semanas;
  }
}

/// Monta o resumo de evolução de um exercício. Devolve `null` quando há
/// menos de 2 registros — sem dois pontos não há evolução para mostrar.
/// [registros] pode vir em qualquer ordem; são ordenados por data aqui.
EvolucaoCarga? resumirEvolucao(String exercicioId, List<RegistroCarga> registros) {
  final doExercicio = registros.where((r) => r.exercicioId == exercicioId).toList()
    ..sort((a, b) => a.data.compareTo(b.data));
  if (doExercicio.length < 2) return null;

  return EvolucaoCarga(
    exercicioId: exercicioId,
    pesos: [for (final r in doExercicio) r.pesoKg],
    pesoInicial: doExercicio.first.pesoKg,
    pesoAtual: doExercicio.last.pesoKg,
    primeiroEm: doExercicio.first.data,
    ultimoEm: doExercicio.last.data,
    totalRegistros: doExercicio.length,
  );
}

/// Um resumo por exercício que tem histórico suficiente, do mais
/// recentemente atualizado para o mais antigo.
List<EvolucaoCarga> resumirTodasAsEvolucoes(List<RegistroCarga> registros) {
  final ids = {for (final r in registros) r.exercicioId};
  final evolucoes = <EvolucaoCarga>[];
  for (final id in ids) {
    final evolucao = resumirEvolucao(id, registros);
    if (evolucao != null) evolucoes.add(evolucao);
  }
  evolucoes.sort((a, b) => b.ultimoEm.compareTo(a.ultimoEm));
  return evolucoes;
}

/// Mensagem de reforço mostrada logo depois de registrar uma carga, quando
/// o registro que acabou de entrar é um novo recorde de peso para aquele
/// exercício (com repetições iguais ou maiores que o recorde anterior, pra
/// não comemorar um peso maior com muito menos volume). [registros] deve
/// incluir o registro recém-adicionado. Devolve `null` quando não há
/// destaque.
String? destaqueNovoRecorde(String exercicioId, List<RegistroCarga> registros) {
  final doExercicio = registros.where((r) => r.exercicioId == exercicioId).toList()
    ..sort((a, b) => a.data.compareTo(b.data));
  if (doExercicio.length < 2) return null;

  final atual = doExercicio.last;
  final anteriores = doExercicio.sublist(0, doExercicio.length - 1);
  final melhorAnterior = anteriores.reduce((a, b) => b.pesoKg >= a.pesoKg ? b : a);

  final subiuPeso = atual.pesoKg > melhorAnterior.pesoKg;
  final manteveVolume = atual.repeticoes >= melhorAnterior.repeticoes;
  if (!subiuPeso || !manteveVolume) return null;

  return 'Novo recorde neste exercício: ${_kg(atual.pesoKg)} '
      '(antes o melhor era ${_kg(melhorAnterior.pesoKg)}). Mandou bem!';
}

String _kg(double v) => '${v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1)} kg';
