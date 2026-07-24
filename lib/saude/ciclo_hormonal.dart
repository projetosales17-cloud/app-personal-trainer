/// Fase aproximada do ciclo menstrual, usada para ajustar volume/
/// intensidade de treino e dar sugestões nutricionais simples — regra de
/// negócio sem IA e sem custo recorrente (ver briefing do produto). Não é
/// um cálculo médico preciso, apenas uma aproximação a partir de um ciclo
/// médio de 28 dias.
enum FaseCiclo { menstrual, folicular, ovulacao, lutea }

extension FaseCicloLabel on FaseCiclo {
  String get label => switch (this) {
    FaseCiclo.menstrual => 'Menstrual',
    FaseCiclo.folicular => 'Folicular',
    FaseCiclo.ovulacao => 'Ovulação',
    FaseCiclo.lutea => 'Lútea',
  };
}

const duracaoCicloDiasPadrao = 28;

/// Calcula a fase aproximada do ciclo a partir da data da última
/// menstruação e de uma data de referência (padrão: agora). Assume um
/// ciclo médio de 28 dias, dividido em: menstrual (dias 0-4), folicular
/// (dias 5-12), ovulação (dias 13-15) e lútea (dias 16-27).
FaseCiclo calcularFaseCiclo(DateTime dataUltimaMenstruacao, {DateTime? referencia}) {
  final hoje = referencia ?? DateTime.now();
  final inicio = DateTime(
    dataUltimaMenstruacao.year,
    dataUltimaMenstruacao.month,
    dataUltimaMenstruacao.day,
  );
  final fimDoDia = DateTime(hoje.year, hoje.month, hoje.day);
  final diasDesde = fimDoDia.difference(inicio).inDays;
  final diaDoCiclo = diasDesde % duracaoCicloDiasPadrao;

  return switch (diaDoCiclo) {
    <= 4 => FaseCiclo.menstrual,
    <= 12 => FaseCiclo.folicular,
    <= 15 => FaseCiclo.ovulacao,
    _ => FaseCiclo.lutea,
  };
}
