import '../models/anamnese.dart';
import 'sexo.dart';
import 'util.dart';

const fatoresAtividade = {
  NivelAtividade.sedentario: 1.2,
  NivelAtividade.leve: 1.375,
  NivelAtividade.moderado: 1.55,
  NivelAtividade.intenso: 1.725,
  NivelAtividade.muitoIntenso: 1.9,
};

/// Taxa Metabólica Basal pela fórmula de Mifflin-St Jeor.
double calcularTmb(double pesoKg, double alturaCm, int idade, Sexo sexo) {
  if (pesoKg <= 0 || alturaCm <= 0 || idade <= 0) {
    throw ArgumentError('Peso, altura e idade devem ser valores positivos');
  }

  var tmb = 10 * pesoKg + 6.25 * alturaCm - 5 * idade;
  tmb += sexo == Sexo.masculino ? 5 : -161;
  return arredondar(tmb);
}

double calcularGastoCaloricoDiario(double tmb, NivelAtividade nivelAtividade) {
  return arredondar(tmb * fatoresAtividade[nivelAtividade]!);
}
