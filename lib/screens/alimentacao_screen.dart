import 'package:flutter/material.dart';

import 'biblioteca_alimentos_view.dart';
import 'hidratacao_view.dart';
import 'meu_cardapio_view.dart';

/// Diário alimentar, receitas e suplementação ainda não foram implementados
/// (ver briefing do produto).
class AlimentacaoScreen extends StatelessWidget {
  const AlimentacaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Alimentação'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Biblioteca'),
              Tab(text: 'Cardápio'),
              Tab(text: 'Hidratação'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BibliotecaAlimentosView(),
            MeuCardapioView(),
            HidratacaoView(),
          ],
        ),
      ),
    );
  }
}
