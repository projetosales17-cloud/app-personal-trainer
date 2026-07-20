import 'dart:math' as math;

import 'sexo.dart';
import 'util.dart';

double _log10(double valor) => math.log(valor) / math.ln10;

/// Estimativa de percentual de gordura corporal pela fórmula da Marinha dos
/// EUA (U.S. Navy Method), baseada em medidas de circunferência corporal.
/// Todas as medidas devem ser informadas em centímetros.
double calcularPercentualGordura({
  required Sexo sexo,
  required double alturaCm,
  required double pescocoCm,
  required double cinturaCm,
  double? quadrilCm,
}) {
  if (alturaCm <= 0 || pescocoCm <= 0 || cinturaCm <= 0) {
    throw ArgumentError('Altura, pescoço e cintura devem ser valores positivos');
  }

  double denominador;
  if (sexo == Sexo.masculino) {
    if (cinturaCm <= pescocoCm) {
      throw ArgumentError('Cintura deve ser maior que o pescoço');
    }
    denominador = 1.0324 -
        0.19077 * _log10(cinturaCm - pescocoCm) +
        0.15456 * _log10(alturaCm);
  } else {
    if (quadrilCm == null || quadrilCm <= 0) {
      throw ArgumentError("Quadril é obrigatório e deve ser positivo para sexo feminino");
    }
    if (cinturaCm + quadrilCm <= pescocoCm) {
      throw ArgumentError('Cintura + quadril deve ser maior que o pescoço');
    }
    denominador = 1.29579 -
        0.35004 * _log10(cinturaCm + quadrilCm - pescocoCm) +
        0.22100 * _log10(alturaCm);
  }

  return arredondar(495 / denominador - 450);
}
