import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/registro_foto.dart';
import '../services/progresso_repository.dart';
import '../widgets/ajuda_fotos_progresso.dart';
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

/// Quantas fotos a grade carrega por vez. Mantém a tela leve mesmo com
/// centenas de fotos na jornada.
const _tamanhoPagina = 24;

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
  final List<RegistroFoto> _fotos = [];
  bool _carregandoPagina = false;
  bool _primeiraCargaFeita = false;
  bool _temMais = true;
  bool _enviando = false;
  PoseFoto _pose = PoseFoto.frente;

  @override
  void initState() {
    super.initState();
    _carregarMais();
  }

  Future<void> _carregarMais() async {
    if (_carregandoPagina || !_temMais) return;
    _carregandoPagina = true;
    final novas = await widget.repositorio.paginaFotos(
      limite: _tamanhoPagina,
      antesDe: _fotos.isEmpty ? null : _fotos.last.data,
    );
    if (!mounted) return;
    setState(() {
      _fotos.addAll(novas);
      _temMais = novas.length == _tamanhoPagina;
      _carregandoPagina = false;
      _primeiraCargaFeita = true;
    });
  }

  Future<void> _recarregarDoInicio() async {
    setState(() {
      _fotos.clear();
      _temMais = true;
      _primeiraCargaFeita = false;
      _carregandoPagina = false;
    });
    await _carregarMais();
  }

  Future<void> _adicionar(ImageSource fonte) async {
    if (_enviando) return;
    final bytes = await widget.selecionarImagem(fonte);
    if (bytes == null || !mounted) return;

    if (bytes.lengthInBytes > _limiteBytesFoto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto demasiado pesada. Prueba con otra o una de menor resolución.'),
        ),
      );
      return;
    }

    setState(() => _enviando = true);
    try {
      await widget.repositorio.registrarFoto(bytes, pose: _pose);
    } finally {
      if (mounted) {
        setState(() => _enviando = false);
        await _recarregarDoInicio();
      }
    }
  }

  Future<void> _abrir(RegistroFoto foto) async {
    final removida = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FotoDetalheScreen(foto: foto, repositorio: widget.repositorio),
      ),
    );
    // A foto já foi apagada no repositório — some da grade na hora, sem
    // reler do Firestore (que ainda pode devolver a foto por um instante).
    if (removida == true && mounted) {
      setState(() => _fotos.removeWhere((f) => f.id == foto.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto eliminada.')),
      );
    }
  }

  String _legenda(RegistroFoto foto) {
    final data = _formatarData(foto.data);
    return foto.pose == PoseFoto.livre ? data : '${foto.pose.label} · $data';
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
                child: Text('Ángulo de la foto', style: Theme.of(context).textTheme.titleSmall),
              ),
              const BotaoAjudaFotosProgresso(),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              children: [
                for (final pose in PoseFoto.values)
                  ChoiceChip(
                    key: Key('chip-pose-${pose.name}'),
                    label: Text(pose.label),
                    selected: _pose == pose,
                    onSelected: (_) => setState(() => _pose = pose),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('botao-camera'),
                  onPressed: _enviando ? null : () => _adicionar(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Cámara'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('botao-galeria'),
                  onPressed: _enviando ? null : () => _adicionar(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galería'),
                ),
              ),
            ],
          ),
          if (_enviando) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          const SizedBox(height: 16),
          Expanded(child: _grade(context)),
        ],
      ),
    );
  }

  Widget _grade(BuildContext context) {
    if (!_primeiraCargaFeita) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_fotos.isEmpty) {
      return const Center(
        child: Text('Aún no hay fotos. Agrega la primera arriba.'),
      );
    }

    return GridView.builder(
      key: const Key('grade-fotos'),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _fotos.length + (_temMais ? 1 : 0),
      itemBuilder: (context, indice) {
        if (indice >= _fotos.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _carregarMais());
          return const Center(
            child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()),
          );
        }
        final foto = _fotos[indice];
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
                      _legenda(foto),
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
  }
}
