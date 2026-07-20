import 'package:flutter/material.dart';

import 'registro_medidas_view.dart';
import 'registro_peso_view.dart';

/// Fotos/vídeos, timeline antes/depois e gráficos ainda não foram
/// implementados (ver briefing do produto).
class ProgressoScreen extends StatelessWidget {
  const ProgressoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Progresso'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Peso'),
              Tab(text: 'Medidas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RegistroPesoView(),
            RegistroMedidasView(),
          ],
        ),
      ),
    );
  }
}
