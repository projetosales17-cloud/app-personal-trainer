import '../data/biblioteca_exercicios.dart';
import '../models/exercicio.dart';

class BibliotecaExerciciosRepository {
  List<Exercicio> todos() => bibliotecaExercicios;

  List<Exercicio> filtrar({
    GrupoMuscular? grupoMuscular,
    NivelExercicio? nivel,
    ObjetivoExercicio? objetivo,
  }) {
    return bibliotecaExercicios.where((exercicio) {
      if (grupoMuscular != null && exercicio.grupoMuscularPrincipal != grupoMuscular) {
        return false;
      }
      if (nivel != null && exercicio.nivel != nivel) {
        return false;
      }
      if (objetivo != null && !exercicio.objetivos.contains(objetivo)) {
        return false;
      }
      return true;
    }).toList();
  }

  Exercicio? porId(String id) {
    for (final exercicio in bibliotecaExercicios) {
      if (exercicio.id == id) return exercicio;
    }
    return null;
  }
}
