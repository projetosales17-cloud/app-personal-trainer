import 'package:flutter/material.dart';

import 'biblioteca_alimentos_view.dart';
import 'hidratacao_view.dart';

/// Cardápio gerado, diário alimentar, receitas e suplementação ainda não
/// foram implementados (ver briefing do produto).
class AlimentacaoScreen extends StatelessWidget {
  const AlimentacaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Alimentação'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Biblioteca'),
              Tab(text: 'Hidratação'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BibliotecaAlimentosView(),
            HidratacaoView(),
          ],
        ),
      ),
    );
  }
}
