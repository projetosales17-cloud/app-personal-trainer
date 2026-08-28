/// Fase aproximada do ciclo menstrual, usada para ajustar volume/
/// intensidade de treino e dar sugestões nutricionais simples — regra de
/// negócio sem IA e sem custo recorrente (ver briefing do produto). Não é
/// um cálculo médico preciso, apenas uma aproximação.
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

/// Faixa aceita para a duração média do ciclo informada pela usuária.
/// Valores fora disso são ajustados para o limite mais próximo.
const duracaoCicloMinima = 21;
const duracaoCicloMaxima = 40;

/// Dias de menstruação no início do ciclo (fase menstrual). Não varia muito
/// com a duração total do ciclo, então fica fixo.
const _diasMenstruacao = 5;

/// A fase lútea (da ovulação até a próxima menstruação) tem duração
/// relativamente constante, ~14 dias. A variação da duração total do ciclo
/// recai quase toda sobre a fase folicular. Por isso a ovulação é contada
/// a partir do fim do ciclo, não do início.
const _diasLuteaAproximados = 14;

/// Calcula a fase aproximada do ciclo a partir da data da última
/// menstruação e de uma data de referência (padrão: agora).
///
/// [duracaoCiclo] é a duração média do ciclo da usuária (1º dia de uma
/// menstruação até o 1º dia da próxima). O padrão de 28 dias reproduz
/// exatamente o comportamento anterior: menstrual (0-4), folicular (5-12),
/// ovulação (13-15) e lútea (16-27). Ciclos mais curtos ou mais longos
/// deslocam a janela de ovulação mantendo a fase lútea com ~14 dias.
FaseCiclo calcularFaseCiclo(
  DateTime dataUltimaMenstruacao, {
  DateTime? referencia,
  int duracaoCiclo = duracaoCicloDiasPadrao,
}) {
  final duracao = duracaoCiclo.clamp(duracaoCicloMinima, duracaoCicloMaxima);

  final hoje = referencia ?? DateTime.now();
  final inicio = DateTime(
    dataUltimaMenstruacao.year,
    dataUltimaMenstruacao.month,
    dataUltimaMenstruacao.day,
  );
  final fimDoDia = DateTime(hoje.year, hoje.month, hoje.day);
  final diasDesde = fimDoDia.difference(inicio).inDays;
  final diaDoCiclo = diasDesde % duracao;

  // Janela de ovulação: um dia antes e um depois do pico estimado, contado
  // a partir do fim do ciclo. Nunca antes do fim da menstruação.
  final inicioOvulacao =
      (duracao - _diasLuteaAproximados - 1).clamp(_diasMenstruacao, duracao - 1);
  final fimOvulacao = (duracao - _diasLuteaAproximados + 1).clamp(inicioOvulacao, duracao - 1);

  if (diaDoCiclo < _diasMenstruacao) return FaseCiclo.menstrual;
  if (diaDoCiclo < inicioOvulacao) return FaseCiclo.folicular;
  if (diaDoCiclo <= fimOvulacao) return FaseCiclo.ovulacao;
  return FaseCiclo.lutea;
}
