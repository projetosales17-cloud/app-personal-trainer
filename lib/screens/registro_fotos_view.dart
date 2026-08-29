import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/registro_foto.dart';
import '../services/progresso_repository.dart';
import 'foto_detalhe_screen.dart';

typedef SelecionarImagem = Future<Uint8List?> Function(ImageSource fonte);

Future<Uint8List?> _selecionarImagemPadrao(ImageSource fonte) async {
  final arquivo = await ImagePicker().pickImage(
    source: fonte,
    maxWidth: 1280,
    maxHeight: 1280,
    imageQuality: 55,
  );
  return arquivo?.readAsBytes();
}

/// Acima deste tamanho a foto não cabe com folga num documento do
/// Firestore (limite de 1 MB; base64 infla ~33%).
const _limiteBytesFoto = 700 * 1024;

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
  bool _enviando = false;

  Future<void> _adicionar(ImageSource fonte) async {
    if (_enviando) return;
    final bytes = await widget.selecionarImagem(fonte);
    if (bytes == null || !mounted) return;

    if (bytes.lengthInBytes > _limiteBytesFoto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto muito pesada. Tente outra ou uma de menor resolução.'),
        ),
      );
      return;
    }

    setState(() => _enviando = true);
    try {
      await widget.repositorio.registrarFoto(bytes);
    } finally {
      if (mounted) {
        setState(() {
          _enviando = false;
          _fotosFuture = widget.repositorio.listarFotos();
        });
      }
    }
  }

  Future<void> _abrir(RegistroFoto foto) async {
    final removida = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FotoDetalheScreen(foto: foto, repositorio: widget.repositorio),
      ),
    );
    if (removida == true && mounted) {
      setState(() => _fotosFuture = widget.repositorio.listarFotos());
    }
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
                  onPressed: _enviando ? null : () => _adicionar(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Câmera'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('botao-galeria'),
                  onPressed: _enviando ? null : () => _adicionar(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galeria'),
                ),
              ),
            ],
          ),
          if (_enviando) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
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
                      onTap: () => _abrir(foto),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(foto.bytes, fit: BoxFit.cover, gaplessPlayback: true),
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
