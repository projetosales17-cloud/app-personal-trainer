import '../data/biblioteca_orientacoes.dart';
import '../models/orientacao.dart';

class BibliotecaOrientacoesRepository {
  List<Orientacao> todos() => bibliotecaOrientacoes;

  List<Orientacao> filtrar({
    TemaOrientacao? tema,
    TipoConteudoOrientacao? tipo,
    String busca = '',
  }) {
    final termo = busca.trim().toLowerCase();
    return bibliotecaOrientacoes.where((orientacao) {
      if (tema != null && orientacao.tema != tema) {
        return false;
      }
      if (tipo != null && orientacao.tipo != tipo) {
        return false;
      }
      if (termo.isNotEmpty &&
          !orientacao.titulo.toLowerCase().contains(termo) &&
          !orientacao.corpo.toLowerCase().contains(termo)) {
        return false;
      }
      return true;
    }).toList();
  }

  Orientacao? porId(String id) {
    for (final orientacao in bibliotecaOrientacoes) {
      if (orientacao.id == id) return orientacao;
    }
    return null;
  }
}
