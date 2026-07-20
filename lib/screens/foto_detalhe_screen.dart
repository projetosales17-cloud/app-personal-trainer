import 'dart:io';

import 'package:flutter/material.dart';

import '../models/registro_foto.dart';

class FotoDetalheScreen extends StatelessWidget {
  const FotoDetalheScreen({super.key, required this.foto});

  final RegistroFoto foto;

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_formatarData(foto.data))),
      body: Center(child: Image.file(File(foto.caminhoArquivo))),
    );
  }
}
