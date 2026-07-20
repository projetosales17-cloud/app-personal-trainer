import 'package:flutter/material.dart';

/// Tela genérica usada enquanto uma seção do app ainda não foi implementada.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.titulo,
    required this.descricao,
  });

  final String titulo;
  final String descricao;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            descricao,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
