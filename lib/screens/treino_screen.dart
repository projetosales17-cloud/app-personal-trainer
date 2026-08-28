import 'package:flutter/material.dart';

import '../services/anamnese_repository.dart';
import 'biblioteca_exercicios_view.dart';
import 'minha_ficha_view.dart';

/// Calendário com histórico, cronômetro de descanso e registro de carga
/// ainda não foram implementados (ver briefing do produto).
class TreinoScreen extends StatelessWidget {
  const TreinoScreen({super.key, this.anamneseRepositorio});

  final AnamneseRepository? anamneseRepositorio;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Treino'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Minha ficha'),
              Tab(text: 'Biblioteca'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MinhaFichaView(anamneseRepositorio: anamneseRepositorio),
            BibliotecaExerciciosView(anamneseRepositorio: anamneseRepositorio),
          ],
        ),
      ),
    );
  }
}
