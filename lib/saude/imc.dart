import 'util.dart';

double calcularImc(double pesoKg, double alturaM) {
  if (pesoKg <= 0 || alturaM <= 0) {
    throw ArgumentError('Peso e altura devem ser valores positivos');
  }
  return arredondar(pesoKg / (alturaM * alturaM));
}

String classificarImc(double imc) {
  if (imc < 18.5) return 'Abaixo do peso';
  if (imc < 25) return 'Peso normal';
  if (imc < 30) return 'Sobrepeso';
  return 'Obesidade';
}

const _recomendacaoMedicaImc =
    'Este valor está fora da faixa considerada saudável. Recomendamos '
    'procurar um médico e realizar exames antes de iniciar ou continuar '
    'um programa de treino.';

/// Retorna uma recomendação de avaliação médica para IMC em faixa grave
/// (magreza severa ou obesidade grave), ou null quando não há risco
/// imediato. Não é um diagnóstico médico.
String? verificarAlertaSaude(double imc) {
  if (imc < 16 || imc >= 40) return _recomendacaoMedicaImc;
  return null;
}
