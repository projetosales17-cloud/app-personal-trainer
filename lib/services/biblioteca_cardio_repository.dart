import '../data/biblioteca_cardio.dart';
import '../models/atividade_cardio.dart';

class BibliotecaCardioRepository {
  List<AtividadeCardio> todas() => bibliotecaCardio;

  List<AtividadeCardio> filtrar({LocalTreino? local, bool? baixoImpacto}) {
    return bibliotecaCardio.where((atividade) {
      if (local != null && atividade.local != local) return false;
      if (baixoImpacto != null && atividade.baixoImpacto != baixoImpacto) return false;
      return true;
    }).toList();
  }
}
