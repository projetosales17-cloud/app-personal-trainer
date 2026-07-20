import '../models/anamnese.dart';
import 'util.dart';

const _mlPorKg = 35;

const _extraMlPorAtividade = {
  NivelAtividade.sedentario: 0,
  NivelAtividade.leve: 350,
  NivelAtividade.moderado: 550,
  NivelAtividade.intenso: 750,
  NivelAtividade.muitoIntenso: 1000,
};

/// Retorna a hidratação diária recomendada, em mililitros.
double calcularHidratacaoDiaria(double pesoKg, NivelAtividade nivelAtividade) {
  if (pesoKg <= 0) {
    throw ArgumentError('Peso deve ser um valor positivo');
  }

  final baseMl = pesoKg * _mlPorKg;
  final extraMl = _extraMlPorAtividade[nivelAtividade]!;
  return arredondar(baseMl + extraMl);
}
