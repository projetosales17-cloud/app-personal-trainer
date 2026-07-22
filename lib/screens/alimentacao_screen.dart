import 'package:flutter/material.dart';

import 'biblioteca_alimentos_view.dart';
import 'diario_alimentar_view.dart';
import 'hidratacao_view.dart';
import 'meu_cardapio_view.dart';
import 'receitas_view.dart';
import 'suplementos_view.dart';

class AlimentacaoScreen extends StatelessWidget {
  const AlimentacaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Alimentação'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Biblioteca'),
              Tab(text: 'Cardápio'),
              Tab(text: 'Receitas'),
              Tab(text: 'Diário'),
              Tab(text: 'Hidratação'),
              Tab(text: 'Suplementos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BibliotecaAlimentosView(),
            MeuCardapioView(),
            ReceitasView(),
            DiarioAlimentarView(),
            HidratacaoView(),
            SuplementosView(),
          ],
        ),
      ),
    );
  }
}
