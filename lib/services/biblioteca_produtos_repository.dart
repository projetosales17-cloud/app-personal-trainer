import '../data/biblioteca_produtos.dart';
import '../models/produto.dart';

class BibliotecaProdutosRepository {
  List<Produto> todos() => bibliotecaProdutos;

  List<Produto> filtrar({TagPerfil? tag}) {
    if (tag == null) return bibliotecaProdutos;
    return bibliotecaProdutos.where((produto) => produto.tags.contains(tag)).toList();
  }
}
