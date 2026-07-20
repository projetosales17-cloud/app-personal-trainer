/// Triagem de risco pré-atividade física.
///
/// Este arquivo NÃO faz diagnóstico médico. Aplica critérios de referência
/// amplamente reconhecidos (classificação de pressão arterial da American
/// Heart Association e o questionário PAR-Q) para sinalizar quando uma
/// pessoa deve procurar avaliação médica antes de iniciar ou retomar um
/// programa de exercícios.
library;

const _recomendacaoMedica =
    'Recomendamos procurar um médico e realizar exames antes de iniciar ou '
    'continuar um programa de atividade física.';

const _recomendacaoUrgente =
    'Valores compatíveis com crise hipertensiva. Procure atendimento médico '
    'imediatamente antes de praticar qualquer atividade física.';

const _categoriasPressaoComRisco = {
  'Hipotensão',
  'Hipertensão estágio 1',
  'Hipertensão estágio 2',
  'Crise hipertensiva',
};

/// Classifica a pressão arterial segundo critérios da American Heart
/// Association (valores em mmHg).
String classificarPressaoArterial(double sistolica, double diastolica) {
  if (sistolica <= 0 || diastolica <= 0) {
    throw ArgumentError('Sistólica e diastólica devem ser valores positivos');
  }

  if (sistolica >= 180 || diastolica >= 120) return 'Crise hipertensiva';
  if (sistolica >= 140 || diastolica >= 90) return 'Hipertensão estágio 2';
  if (sistolica >= 130 || diastolica >= 80) return 'Hipertensão estágio 1';
  if (sistolica < 90 || diastolica < 60) return 'Hipotensão';
  if (sistolica >= 120) return 'Pressão elevada';
  return 'Normal';
}

String? verificarAlertaPressaoArterial(String categoria) {
  if (categoria == 'Crise hipertensiva') return _recomendacaoUrgente;
  if (_categoriasPressaoComRisco.contains(categoria)) return _recomendacaoMedica;
  return null;
}

const perguntasParQ = {
  'problemaCardiaco':
      'Um médico já disse que você possui um problema cardíaco e '
      'recomendou realizar atividade física apenas sob supervisão?',
  'dorPeitoAtividade': 'Você sente dor no peito ao praticar atividade física?',
  'dorPeitoRepouso':
      'No último mês, você sentiu dor no peito quando não estava '
      'praticando atividade física?',
  'tonturaDesequilibrio':
      'Você perde o equilíbrio por tontura ou já perdeu a consciência?',
  'problemaOsseoArticular':
      'Você tem algum problema ósseo ou articular que poderia piorar com '
      'uma mudança na sua atividade física?',
  'medicamentoPressaoCoracao':
      'Um médico prescreveu atualmente medicamentos para pressão arterial '
      'ou para o coração?',
  'outroMotivo':
      'Você conhece qualquer outro motivo pelo qual não deveria praticar '
      'atividade física?',
};

/// Aplica o questionário PAR-Q. `respostas` mapeia um subconjunto das
/// chaves de [perguntasParQ] para true (sim) ou false (não); perguntas não
/// informadas são tratadas como "não". Retorna a lista de perguntas
/// respondidas como "sim" — qualquer resposta positiva indica que a pessoa
/// deve consultar um médico antes de aumentar o nível de atividade física.
List<String> triagemParQ(Map<String, bool> respostas) {
  return [
    for (final entrada in perguntasParQ.entries)
      if (respostas[entrada.key] ?? false) entrada.value,
  ];
}

class ResultadoTriagem {
  const ResultadoTriagem({
    required this.liberado,
    required this.alertas,
    required this.recomendacao,
  });

  final bool liberado;
  final List<String> alertas;
  final String recomendacao;
}

const _recomendacaoSemFatoresDeRisco =
    'Nenhum fator de risco identificado no PAR-Q. Ainda assim, '
    'recomenda-se avaliação médica periódica antes de iniciar um programa '
    'de exercícios.';

ResultadoTriagem avaliarLiberacaoAtividadeFisica(Map<String, bool> respostas) {
  final alertas = triagemParQ(respostas);
  if (alertas.isNotEmpty) {
    return ResultadoTriagem(
      liberado: false,
      alertas: alertas,
      recomendacao: _recomendacaoMedica,
    );
  }
  return const ResultadoTriagem(
    liberado: true,
    alertas: [],
    recomendacao: _recomendacaoSemFatoresDeRisco,
  );
}
