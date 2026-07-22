import '../data/biblioteca_suplementos.dart';
import '../models/suplemento.dart';

class BibliotecaSuplementosRepository {
  List<Suplemento> todos() => bibliotecaSuplementos;

  List<Suplemento> filtrar({TipoSuplemento? tipo}) {
    if (tipo == null) return bibliotecaSuplementos;
    return bibliotecaSuplementos.where((suplemento) => suplemento.tipo == tipo).toList();
  }
}
