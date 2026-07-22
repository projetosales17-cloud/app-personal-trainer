import 'dart:io';

import 'package:flutter/material.dart';

import '../models/registro_foto.dart';
import '../services/progresso_repository.dart';
import 'foto_detalhe_screen.dart';

/// Comparação entre a foto mais antiga e a mais recente registradas, mais
/// uma linha do tempo completa com todas as fotos intermediárias.
class AntesDepoisView extends StatefulWidget {
  AntesDepoisView({super.key, ProgressoRepository? repositorio})
    : repositorio = repositorio ?? ProgressoRepository();

  final ProgressoRepository repositorio;

  @override
  State<AntesDepoisView> createState() => _AntesDepoisViewState();
}

class _AntesDepoisViewState extends State<AntesDepoisView> {
  late final Future<List<RegistroFoto>> _fotosFuture = widget.repositorio
      .listarFotos();

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RegistroFoto>>(
      future: _fotosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final fotos = snapshot.data ?? const <RegistroFoto>[];
        if (fotos.length < 2) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Registre pelo menos duas fotos na aba Fotos para ver a comparação '
                'antes/depois.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final antes = fotos.first;
        final depois = fotos.last;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _CartaoFoto(
                      titulo: 'Antes',
                      foto: antes,
                      formatarData: _formatarData,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _CartaoFoto(
                      titulo: 'Depois',
                      foto: depois,
                      formatarData: _formatarData,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Linha do tempo completa',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  key: const Key('linha-do-tempo'),
                  scrollDirection: Axis.horizontal,
                  itemCount: fotos.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, indice) {
                    final foto = fotos[indice];
                    return GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FotoDetalheScreen(foto: foto),
                        ),
                      ),
                      child: SizedBox(
                        width: 100,
                        child: Column(
                          children: [
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 3 / 4,
                                child: Image.file(
                                  File(foto.caminhoArquivo),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatarData(foto.data),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CartaoFoto extends StatelessWidget {
  const _CartaoFoto({
    required this.titulo,
    required this.foto,
    required this.formatarData,
  });

  final String titulo;
  final RegistroFoto foto;
  final String Function(DateTime) formatarData;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(titulo, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 3 / 4,
          child: Image.file(File(foto.caminhoArquivo), fit: BoxFit.cover),
        ),
        const SizedBox(height: 4),
        Text(
          formatarData(foto.data),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
