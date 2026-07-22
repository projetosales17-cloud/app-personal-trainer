import '../data/biblioteca_comunidade.dart';
import '../models/publicacao_comunidade.dart';

class BibliotecaComunidadeRepository {
  List<PublicacaoComunidade> todas() => bibliotecaComunidade;

  List<PublicacaoComunidade> filtrar({TipoPublicacaoComunidade? tipo}) {
    if (tipo == null) return bibliotecaComunidade;
    return bibliotecaComunidade.where((publicacao) => publicacao.tipo == tipo).toList();
  }
}
