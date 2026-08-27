import 'package:flutter/material.dart';

import '../models/anamnese.dart';
import '../models/exercicio.dart';
import '../services/anamnese_repository.dart';
import '../services/biblioteca_exercicios_repository.dart';
import 'exercicio_detalhe_screen.dart';

class BibliotecaExerciciosView extends StatefulWidget {
  BibliotecaExerciciosView({
    super.key,
    BibliotecaExerciciosRepository? repositorio,
    AnamneseRepository? anamneseRepositorio,
  }) : repositorio = repositorio ?? BibliotecaExerciciosRepository(),
       anamneseRepositorio = anamneseRepositorio ?? AnamneseRepository();

  final BibliotecaExerciciosRepository repositorio;
  final AnamneseRepository anamneseRepositorio;

  @override
  State<BibliotecaExerciciosView> createState() => _BibliotecaExerciciosViewState();
}

class _BibliotecaExerciciosViewState extends State<BibliotecaExerciciosView> {
  GrupoMuscular? _filtro;

  /// Quando ligado, esconde exercícios que dependem de equipamento de
  /// academia (barra, halteres, máquina, banco). Vem ligado por padrão
  /// para quem escolheu treinar em casa na anamnese.
  bool _soCasa = false;

  @override
  void initState() {
    super.initState();
    widget.anamneseRepositorio.carregar().then((anamnese) {
      if (!mounted) return;
      setState(() => _soCasa = anamnese?.localTreino == LocalTreino.casa);
    });
  }

  @override
  Widget build(BuildContext context) {
    final exercicios = widget.repositorio.filtrar(
      grupoMuscular: _filtro,
      equipamentos: _soCasa ? equipamentosCasa : null,
    );

    return Column(
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FilterChip(
              key: const Key('filtro-so-casa'),
              avatar: const Icon(Icons.home_outlined, size: 18),
              label: const Text('Em casa (sem equipamento de academia)'),
              selected: _soCasa,
              onSelected: (valor) => setState(() => _soCasa = valor),
            ),
          ),
        ),
        Expanded(
          child: exercicios.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Nenhum exercício para este filtro. Tente desativar '
                      '"Em casa" ou escolher outro grupo muscular.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
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
    );
  }
}
