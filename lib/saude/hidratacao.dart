import '../models/anamnese.dart';
import 'util.dart';

const mlPorKg = 35;

/// Acréscimo para dia quente / treino longo. Não é altura — altura não
/// entra em nenhuma fórmula de hidratação; o que pesa é peso corporal,
/// nível de atividade e o calor/esforço do dia.
const mlDiaQuente = 500;

const extraMlPorAtividade = {
  NivelAtividade.sedentario: 0,
  NivelAtividade.leve: 350,
  NivelAtividade.moderado: 550,
  NivelAtividade.intenso: 750,
  NivelAtividade.muitoIntenso: 1000,
};

/// Retorna a hidratação diária recomendada, em mililitros. [diaQuente]
/// soma [mlDiaQuente] para dias de calor ou treino longo.
double calcularHidratacaoDiaria(
  double pesoKg,
  NivelAtividade nivelAtividade, {
  bool diaQuente = false,
}) {
  if (pesoKg <= 0) {
    throw ArgumentError('El peso debe ser un valor positivo');
  }

  final baseMl = pesoKg * mlPorKg;
  final extraMl = extraMlPorAtividade[nivelAtividade]!;
  return arredondar(baseMl + extraMl + (diaQuente ? mlDiaQuente : 0));
}
