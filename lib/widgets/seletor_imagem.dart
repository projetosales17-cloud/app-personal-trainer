import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Seletor de imagem injetável — a implementação real usa a galeria/câmera
/// do aparelho; os testes passam uma função que devolve bytes fixos.
typedef SelecionarImagem = Future<Uint8List?> Function(ImageSource fonte);

/// Implementação padrão: abre a câmera ou a galeria e já devolve a imagem
/// redimensionada/comprimida, para caber num documento do Firestore.
Future<Uint8List?> selecionarImagemPadrao(ImageSource fonte) async {
  final arquivo = await ImagePicker().pickImage(
    source: fonte,
    maxWidth: 1280,
    maxHeight: 1280,
    imageQuality: 55,
  );
  return arquivo?.readAsBytes();
}
