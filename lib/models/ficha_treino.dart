import 'exercicio.dart';

class DiaDeTreino {
  const DiaDeTreino({
    required this.dia,
    required this.gruposMusculares,
    required this.exercicios,
  });

  final int dia;
  final List<GrupoMuscular> gruposMusculares;
  final List<Exercicio> exercicios;
}

/// Ficha de treino gerada a partir da anamnese. Tem validade definida
/// (ver briefing do produto: "ficha com validade + alertas de troca").
class FichaTreino {
  const FichaTreino({
    required this.dias,
    required this.geradaEm,
    required this.validaAte,
  });

  final List<DiaDeTreino> dias;
  final DateTime geradaEm;
  final DateTime validaAte;

  bool get expirada => DateTime.now().isAfter(validaAte);
}
