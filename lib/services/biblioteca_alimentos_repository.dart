import '../data/biblioteca_alimentos.dart';
import '../models/alimento.dart';

/// A restrição "Diabetes" (ver onboarding) ainda não tem regra de filtro
/// própria aqui — orientação alimentar específica para diabetes precisa ser
/// validada por profissional antes de virar regra automática de exclusão
/// (ver briefing do produto).
class BibliotecaAlimentosRepository {
  List<Alimento> todos() => bibliotecaAlimentos;

  List<Alimento> filtrar({
    CategoriaAlimento? categoria,
    List<String> restricoesUsuaria = const [],
  }) {
    return bibliotecaAlimentos.where((alimento) {
      if (categoria != null && alimento.categoria != categoria) {
        return false;
      }
      if (restricoesUsuaria.contains('Lactose') && alimento.contemLactose) {
        return false;
      }
      if (restricoesUsuaria.contains('Glúten') && alimento.contemGluten) {
        return false;
      }
      if (restricoesUsuaria.contains('Vegetariana') && !alimento.vegetariano) {
        return false;
      }
      if (restricoesUsuaria.contains('Vegana') && !alimento.vegano) {
        return false;
      }
      return true;
    }).toList();
  }

  List<Alimento> substitutos(Alimento alimento, {List<String> restricoesUsuaria = const []}) {
    return filtrar(categoria: alimento.categoria, restricoesUsuaria: restricoesUsuaria)
        .where((candidato) => candidato.id != alimento.id)
        .toList();
  }

  Alimento? porId(String id) {
    for (final alimento in bibliotecaAlimentos) {
      if (alimento.id == id) return alimento;
    }
    return null;
  }
}
