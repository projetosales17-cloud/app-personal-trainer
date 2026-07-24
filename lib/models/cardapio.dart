import 'alimento.dart';

class RefeicaoDoDia {
  const RefeicaoDoDia({required this.nome, required this.alimentos});

  final String nome;
  final List<Alimento> alimentos;
}

class DiaDeCardapio {
  const DiaDeCardapio({required this.dia, required this.refeicoes});

  final int dia;
  final List<RefeicaoDoDia> refeicoes;
}

/// Cardápio gerado a partir da anamnese. Tem validade definida, como a
/// ficha de treino (ver briefing do produto: "ficha com validade + alertas
/// de troca").
class Cardapio {
  const Cardapio({
    required this.dias,
    required this.geradaEm,
    required this.validaAte,
    this.observacaoCiclo,
  });

  final List<DiaDeCardapio> dias;
  final DateTime geradaEm;
  final DateTime validaAte;

  /// Dica nutricional não-prescritiva conforme a fase do ciclo hormonal
  /// informada na anamnese (ver briefing do produto). `null` quando a
  /// usuária não informou ciclo regular.
  final String? observacaoCiclo;

  bool get expirada => DateTime.now().isAfter(validaAte);
}
