import 'package:flutter/material.dart';

import '../models/exercicio.dart';
import '../models/registro_carga.dart';
import '../services/treino_repository.dart';
import '../widgets/cronometro_descanso.dart';

class ExercicioDetalheScreen extends StatefulWidget {
  ExercicioDetalheScreen({super.key, required this.exercicio, TreinoRepository? repositorio})
    : repositorio = repositorio ?? TreinoRepository();

  final Exercicio exercicio;
  final TreinoRepository repositorio;

  @override
  State<ExercicioDetalheScreen> createState() => _ExercicioDetalheScreenState();
}

class _ExercicioDetalheScreenState extends State<ExercicioDetalheScreen> {
  late Future<List<RegistroCarga>> _historicoFuture = _carregarHistorico();
  final _controladorPeso = TextEditingController();
  final _controladorSeries = TextEditingController();
  final _controladorRepeticoes = TextEditingController();

  Future<List<RegistroCarga>> _carregarHistorico() =>
      widget.repositorio.listarCargasDoExercicio(widget.exercicio.id);

  @override
  void dispose() {
    _controladorPeso.dispose();
    _controladorSeries.dispose();
    _controladorRepeticoes.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    final peso = double.tryParse(_controladorPeso.text.replaceAll(',', '.'));
    final series = int.tryParse(_controladorSeries.text);
    final repeticoes = int.tryParse(_controladorRepeticoes.text);
    if (peso == null || series == null || repeticoes == null) return;
    // Peso 0 é válido (exercícios de peso do corpo, como flexão ou prancha).
    if (peso < 0 || series <= 0 || repeticoes <= 0) return;

    await widget.repositorio.registrarCarga(
      RegistroCarga(
        exercicioId: widget.exercicio.id,
        data: DateTime.now(),
        pesoKg: peso,
        series: series,
        repeticoes: repeticoes,
      ),
    );
    _controladorPeso.clear();
    _controladorSeries.clear();
    _controladorRepeticoes.clear();
    setState(() {
      _historicoFuture = _carregarHistorico();
    });
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    final exercicio = widget.exercicio;

    return Scaffold(
      appBar: AppBar(title: Text(exercicio.nome)),
      body: ListView(
        key: const Key('lista-exercicio-detalhe'),
        padding: const EdgeInsets.all(24),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(exercicio.grupoMuscularPrincipal.label)),
              for (final secundario in exercicio.gruposMuscularesSecundarios)
                Chip(label: Text(secundario.label), visualDensity: VisualDensity.compact),
              Chip(label: Text(exercicio.nivel.label)),
              Chip(label: Text(exercicio.equipamento.label)),
              for (final objetivo in exercicio.objetivos) Chip(label: Text(objetivo.label)),
            ],
          ),
          const SizedBox(height: 24),
          Text('Como executar', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (exercicio.caminhoImagem != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                exercicio.caminhoImagem!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(exercicio.instrucoes, style: Theme.of(context).textTheme.bodyLarge),
          if (exercicio.caminhoImagem == null) ...[
            const SizedBox(height: 24),
            Text(
              'Imagem de demonstração em breve.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text('Cronômetro de descanso', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const CronometroDescanso(),
          const SizedBox(height: 24),
          Text('Registrar carga', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('campo-peso-carga'),
                  controller: _controladorPeso,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Peso (kg)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  key: const Key('campo-series'),
                  controller: _controladorSeries,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Séries'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  key: const Key('campo-repeticoes'),
                  controller: _controladorRepeticoes,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Repetições'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              key: const Key('botao-registrar-carga'),
              onPressed: _registrar,
              child: const Text('Registrar'),
            ),
          ),
          const SizedBox(height: 24),
          Text('Histórico', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          FutureBuilder<List<RegistroCarga>>(
            future: _historicoFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              final historico = (snapshot.data ?? const <RegistroCarga>[]).reversed.toList();
              if (historico.isEmpty) {
                return const Text('Nenhum registro de carga ainda para este exercício.');
              }

              return Column(
                key: const Key('lista-historico-carga'),
                children: [
                  for (final registro in historico)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${registro.pesoKg.toStringAsFixed(1)} kg · '
                        '${registro.series}x${registro.repeticoes}',
                      ),
                      subtitle: Text(_formatarData(registro.data)),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
