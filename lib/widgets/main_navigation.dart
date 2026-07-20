import 'package:flutter/material.dart';

import '../screens/alimentacao_screen.dart';
import '../screens/home_screen.dart';
import '../screens/orientacoes_screen.dart';
import '../screens/perfil_screen.dart';
import '../screens/progresso_screen.dart';
import '../screens/treino_screen.dart';

/// Estrutura de navegação principal do app, uma aba por seção definida
/// no briefing do produto (Home, Treino, Alimentação, Progresso,
/// Orientações, Perfil).
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _indiceAtual = 0;

  final _telas = [
    HomeScreen(),
    const TreinoScreen(),
    const AlimentacaoScreen(),
    const ProgressoScreen(),
    const OrientacoesScreen(),
    const PerfilScreen(),
  ];

  static const _itens = [
    NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
    NavigationDestination(icon: Icon(Icons.fitness_center_outlined), selectedIcon: Icon(Icons.fitness_center), label: 'Treino'),
    NavigationDestination(icon: Icon(Icons.restaurant_outlined), selectedIcon: Icon(Icons.restaurant), label: 'Alimentação'),
    NavigationDestination(icon: Icon(Icons.show_chart_outlined), selectedIcon: Icon(Icons.show_chart), label: 'Progresso'),
    NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Orientações'),
    NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _indiceAtual, children: _telas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceAtual,
        onDestinationSelected: (indice) => setState(() => _indiceAtual = indice),
        destinations: _itens,
      ),
    );
  }
}
