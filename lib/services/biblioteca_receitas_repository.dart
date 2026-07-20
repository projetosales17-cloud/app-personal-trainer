import '../data/biblioteca_receitas.dart';
import '../models/receita.dart';

/// A restrição "Diabetes" (ver onboarding) ainda não tem regra de filtro
/// própria aqui, mesma decisão já tomada em `BibliotecaAlimentosRepository`.
class BibliotecaReceitasRepository {
  List<Receita> todos() => bibliotecaReceitas;

  List<Receita> filtrar({
    TipoRefeicao? tipoRefeicao,
    List<String> restricoesUsuaria = const [],
    String busca = '',
  }) {
    final termo = busca.trim().toLowerCase();
    return bibliotecaReceitas.where((receita) {
      if (tipoRefeicao != null && receita.tipoRefeicao != tipoRefeicao) {
        return false;
      }
      if (restricoesUsuaria.contains('Lactose') && receita.contemLactose) {
        return false;
      }
      if (restricoesUsuaria.contains('Glúten') && receita.contemGluten) {
        return false;
      }
      if (restricoesUsuaria.contains('Vegetariana') && !receita.vegetariano) {
        return false;
      }
      if (restricoesUsuaria.contains('Vegana') && !receita.vegano) {
        return false;
      }
      if (termo.isNotEmpty && !receita.titulo.toLowerCase().contains(termo)) {
        return false;
      }
      return true;
    }).toList();
  }

  Receita? porId(String id) {
    for (final receita in bibliotecaReceitas) {
      if (receita.id == id) return receita;
    }
    return null;
  }
}
