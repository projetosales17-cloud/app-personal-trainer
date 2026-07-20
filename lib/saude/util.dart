import 'dart:math' as math;

double arredondar(double valor, [int casas = 2]) {
  final fator = math.pow(10, casas);
  return (valor * fator).round() / fator;
}
