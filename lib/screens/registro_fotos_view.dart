import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/registro_foto.dart';
import '../services/progresso_repository.dart';
import 'foto_detalhe_screen.dart';

typedef SelecionarImagem = Future<String?> Function(ImageSource fonte);

Future<String?> _selecionarImagemPadrao(ImageSource fonte) async {
  final arquivo = await ImagePicker().pickImage(source: fonte, imageQuality: 85);
  return arquivo?.path;
}

class RegistroFotosView extends StatefulWidget {
  RegistroFotosView({
    super.key,
    ProgressoRepository? repositorio,
    SelecionarImagem? selecionarImagem,
  }) : repositorio = repositorio ?? ProgressoRepository(),
       selecionarImagem = selecionarImagem ?? _selecionarImagemPadrao;

  final ProgressoRepository repositorio;
  final SelecionarImagem selecionarImagem;

  @override
  State<RegistroFotosView> createState() => _RegistroFotosViewState();
}

class _RegistroFotosViewState extends State<RegistroFotosView> {
  late Future<List<RegistroFoto>> _fotosFuture = widget.repositorio.listarFotos();

  Future<void> _adicionar(ImageSource fonte) async {
    final caminho = await widget.selecionarImagem(fonte);
    if (caminho == null) return;

    await widget.repositorio.registrarFoto(File(caminho));
    setState(() {
      _fotosFuture = widget.repositorio.listarFotos();
    });
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('botao-camera'),
                  onPressed: () => _adicionar(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Câmera'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('botao-galeria'),
                  onPressed: () => _adicionar(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galeria'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<RegistroFoto>>(
              future: _fotosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                final fotos = (snapshot.data ?? const <RegistroFoto>[]).reversed.toList();
                if (fotos.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma foto ainda. Adicione a primeira acima.'),
                  );
                }

                return GridView.builder(
                  key: const Key('grade-fotos'),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: fotos.length,
                  itemBuilder: (context, indice) {
                    final foto = fotos[indice];
                    return GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => FotoDetalheScreen(foto: foto)),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(File(foto.caminhoArquivo), fit: BoxFit.cover),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: ColoredBox(
                              color: const Color(0x99000000),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  _formatarData(foto.data),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontSize: 10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
