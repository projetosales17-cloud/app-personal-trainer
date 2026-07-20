import 'package:flutter/material.dart';

import 'antes_depois_view.dart';
import 'registro_fotos_view.dart';
import 'registro_medidas_view.dart';
import 'registro_peso_view.dart';
import 'registro_videos_view.dart';

class ProgressoScreen extends StatelessWidget {
  const ProgressoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Progresso'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Peso'),
              Tab(text: 'Medidas'),
              Tab(text: 'Fotos'),
              Tab(text: 'Vídeos'),
              Tab(text: 'Antes/Depois'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RegistroPesoView(),
            RegistroMedidasView(),
            RegistroFotosView(),
            RegistroVideosView(),
            AntesDepoisView(),
          ],
        ),
      ),
    );
  }
}
