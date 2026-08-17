/// Triagem de risco pré-atividade física.
///
/// Este arquivo NÃO faz diagnóstico médico. Aplica critérios de referência
/// amplamente reconhecidos (classificação de pressão arterial da American
/// Heart Association e o questionário PAR-Q) para sinalizar quando uma
/// pessoa deve procurar avaliação médica antes de iniciar ou retomar um
/// programa de exercícios.
library;

const _recomendacaoMedica =
    'Te recomendamos consultar a un médico y hacerte exámenes antes de '
    'iniciar o continuar un programa de actividad física.';

const _recomendacaoUrgente =
    'Valores compatibles con crisis hipertensiva. Busca atención médica '
    'de inmediato antes de practicar cualquier actividad física.';

const _categoriasPressaoComRisco = {
  'Hipotensión',
  'Hipertensión etapa 1',
  'Hipertensión etapa 2',
  'Crisis hipertensiva',
};

/// Classifica a pressão arterial segundo critérios da American Heart
/// Association (valores em mmHg).
String classificarPressaoArterial(double sistolica, double diastolica) {
  if (sistolica <= 0 || diastolica <= 0) {
    throw ArgumentError('La sistólica y la diastólica deben ser valores positivos');
  }

  if (sistolica >= 180 || diastolica >= 120) return 'Crisis hipertensiva';
  if (sistolica >= 140 || diastolica >= 90) return 'Hipertensión etapa 2';
  if (sistolica >= 130 || diastolica >= 80) return 'Hipertensión etapa 1';
  if (sistolica < 90 || diastolica < 60) return 'Hipotensión';
  if (sistolica >= 120) return 'Presión elevada';
  return 'Normal';
}

String? verificarAlertaPressaoArterial(String categoria) {
  if (categoria == 'Crisis hipertensiva') return _recomendacaoUrgente;
  if (_categoriasPressaoComRisco.contains(categoria)) return _recomendacaoMedica;
  return null;
}

const perguntasParQ = {
  'problemaCardiaco':
      '¿Un médico te ha dicho alguna vez que tienes un problema cardíaco y '
      'que solo debes hacer actividad física bajo supervisión?',
  'dorPeitoAtividade': '¿Sientes dolor en el pecho al practicar actividad física?',
  'dorPeitoRepouso':
      'En el último mes, ¿has sentido dolor en el pecho cuando no estabas '
      'haciendo actividad física?',
  'tonturaDesequilibrio':
      '¿Pierdes el equilibrio por mareo o has perdido el conocimiento alguna vez?',
  'problemaOsseoArticular':
      '¿Tienes algún problema óseo o articular que pudiera empeorar con '
      'un cambio en tu actividad física?',
  'medicamentoPressaoCoracao':
      '¿Actualmente un médico te recetó medicamentos para la presión '
      'arterial o para el corazón?',
  'outroMotivo':
      '¿Conoces algún otro motivo por el que no deberías practicar '
      'actividad física?',
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
    'No se identificó ningún factor de riesgo en el PAR-Q. Aun así, se '
    'recomienda una evaluación médica periódica antes de iniciar un '
    'programa de ejercicios.';

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
