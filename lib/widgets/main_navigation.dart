import 'package:flutter/material.dart';

import '../screens/alimentacao_screen.dart';
import '../screens/comunidade_screen.dart';
import '../screens/home_screen.dart';
import '../screens/orientacoes_screen.dart';
import '../screens/perfil_screen.dart';
import '../screens/progresso_screen.dart';
import '../screens/sua_loja_screen.dart';
import '../screens/treino_screen.dart';
import '../services/auth_repository.dart';

/// Estrutura de navegação principal do app, uma aba por seção definida
/// no briefing do produto (Home, Treino, Alimentação, Progresso,
/// Comunidade, Orientações, Tu Tienda, Perfil).
class MainNavigation extends StatefulWidget {
  MainNavigation({super.key, AuthRepository? authRepositorio})
    : authRepositorio = authRepositorio ?? AuthRepository();

  final AuthRepository authRepositorio;

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _indiceAtual = 0;

  late final _telas = [
    HomeScreen(),
    const TreinoScreen(),
    const AlimentacaoScreen(),
    const ProgressoScreen(),
    ComunidadeScreen(),
    OrientacoesScreen(),
    SuaLojaScreen(),
    PerfilScreen(authRepositorio: widget.authRepositorio),
  ];

  static const _itens = [
    NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
    NavigationDestination(icon: Icon(Icons.fitness_center_outlined), selectedIcon: Icon(Icons.fitness_center), label: 'Entrenamiento'),
    NavigationDestination(icon: Icon(Icons.restaurant_outlined), selectedIcon: Icon(Icons.restaurant), label: 'Alimentación'),
    NavigationDestination(icon: Icon(Icons.show_chart_outlined), selectedIcon: Icon(Icons.show_chart), label: 'Progreso'),
    NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups), label: 'Comunidad'),
    NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Guías'),
    // Destaque proposital: ícone preenchido + selo "Novo" para atrair
    // as usuárias que também vendem (ver SuaLojaScreen).
    NavigationDestination(
      icon: Badge(label: Text('Nuevo'), child: Icon(Icons.storefront)),
      selectedIcon: Badge(label: Text('Nuevo'), child: Icon(Icons.storefront)),
      label: 'Tu Tienda',
    ),
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
