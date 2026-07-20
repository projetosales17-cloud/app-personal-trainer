import 'package:flutter/material.dart';

import 'biblioteca_exercicios_view.dart';
import 'minha_ficha_view.dart';

/// Calendário com histórico, cronômetro de descanso e registro de carga
/// ainda não foram implementados (ver briefing do produto).
class TreinoScreen extends StatelessWidget {
  const TreinoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Treino'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Biblioteca'),
              Tab(text: 'Minha ficha'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BibliotecaExerciciosView(),
            MinhaFichaView(),
          ],
        ),
      ),
    );
  }
}
