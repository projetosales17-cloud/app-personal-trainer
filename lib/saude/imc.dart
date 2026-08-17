import 'util.dart';

double calcularImc(double pesoKg, double alturaM) {
  if (pesoKg <= 0 || alturaM <= 0) {
    throw ArgumentError('El peso y la altura deben ser valores positivos');
  }
  return arredondar(pesoKg / (alturaM * alturaM));
}

String classificarImc(double imc) {
  if (imc < 18.5) return 'Bajo peso';
  if (imc < 25) return 'Peso normal';
  if (imc < 30) return 'Sobrepeso';
  return 'Obesidad';
}

const _recomendacaoMedicaImc =
    'Este valor está fuera del rango considerado saludable. Te '
    'recomendamos consultar a un médico y hacerte exámenes antes de '
    'iniciar o continuar un programa de entrenamiento.';

/// Retorna uma recomendação de avaliação médica para IMC em faixa grave
/// (magreza severa ou obesidade grave), ou null quando não há risco
/// imediato. Não é um diagnóstico médico.
String? verificarAlertaSaude(double imc) {
  if (imc < 16 || imc >= 40) return _recomendacaoMedicaImc;
  return null;
}
