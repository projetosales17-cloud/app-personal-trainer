import 'package:flutter/material.dart';

import 'antes_depois_view.dart';
import 'evolucao_carga_view.dart';
import 'registro_fotos_view.dart';
import 'registro_medidas_view.dart';
import 'registro_peso_view.dart';
import 'registro_videos_view.dart';

class ProgressoScreen extends StatelessWidget {
  const ProgressoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Progresso'),
          bottom: TabBar(
            isScrollable: true,
            tabs: const [
              Tab(text: 'Peso'),
              Tab(text: 'Medidas'),
              Tab(text: 'Carga'),
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
            EvolucaoCargaView(),
            RegistroFotosView(),
            RegistroVideosView(),
            AntesDepoisView(),
          ],
        ),
      ),
    );
  }
}
