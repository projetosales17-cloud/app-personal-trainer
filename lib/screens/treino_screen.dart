import 'package:flutter/material.dart';

import '../models/exercicio.dart';
import '../services/biblioteca_exercicios_repository.dart';
import 'exercicio_detalhe_screen.dart';

/// Por enquanto mostra só a biblioteca de exercícios. Calendário semanal,
/// ficha personalizada, cronômetro de descanso e histórico de treinos
/// ainda não foram implementados (ver briefing do produto).
class TreinoScreen extends StatefulWidget {
  TreinoScreen({super.key, BibliotecaExerciciosRepository? repositorio})
    : repositorio = repositorio ?? BibliotecaExerciciosRepository();

  final BibliotecaExerciciosRepository repositorio;

  @override
  State<TreinoScreen> createState() => _TreinoScreenState();
}

class _TreinoScreenState extends State<TreinoScreen> {
  GrupoMuscular? _filtro;

  @override
  Widget build(BuildContext context) {
    final exercicios = widget.repositorio.filtrar(grupoMuscular: _filtro);

    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca de exercícios')),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              key: const Key('filtro-grupos'),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Todos'),
                    selected: _filtro == null,
                    onSelected: (_) => setState(() => _filtro = null),
                  ),
                ),
                for (final grupo in GrupoMuscular.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(grupo.label),
                      selected: _filtro == grupo,
                      onSelected: (_) => setState(() => _filtro = grupo),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              key: const Key('lista-exercicios'),
              itemCount: exercicios.length,
              itemBuilder: (context, indice) {
                final exercicio = exercicios[indice];
                return ListTile(
                  title: Text(exercicio.nome),
                  subtitle: Text('${exercicio.equipamento.label} · ${exercicio.nivel.label}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ExercicioDetalheScreen(exercicio: exercicio),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
