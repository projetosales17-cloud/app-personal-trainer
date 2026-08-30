import 'package:flutter/material.dart';

import '../services/foto_perfil_repository.dart';

/// Avatar circular da usuária: a foto de perfil quando houver, senão as
/// iniciais do nome (e um ícone genérico quando nem nome há). Usado na Home
/// e no Perfil.
class AvatarPerfil extends StatelessWidget {
  const AvatarPerfil({
    super.key,
    required this.dataUri,
    required this.nome,
    this.raio = 24,
  });

  /// Data URI base64 da foto (ver [FotoPerfilRepository]); `null` = sem foto.
  final String? dataUri;

  /// Nome usado para as iniciais quando não há foto.
  final String nome;

  final double raio;

  String get _iniciais {
    final partes = nome.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (partes.isEmpty) return '';
    if (partes.length == 1) return partes.first.characters.first.toUpperCase();
    return (partes.first.characters.first + partes.last.characters.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final bytes = bytesDeDataUri(dataUri);

    if (bytes != null) {
      return CircleAvatar(
        key: const Key('avatar-perfil-foto'),
        radius: raio,
        backgroundImage: MemoryImage(bytes),
      );
    }

    final iniciais = _iniciais;
    return CircleAvatar(
      key: const Key('avatar-perfil-iniciais'),
      radius: raio,
      backgroundColor: esquema.primaryContainer,
      foregroundColor: esquema.onPrimaryContainer,
      child: iniciais.isEmpty
          ? Icon(Icons.person, size: raio)
          : Text(iniciais, style: TextStyle(fontSize: raio * 0.7, fontWeight: FontWeight.w600)),
    );
  }
}
