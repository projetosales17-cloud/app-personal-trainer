import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/exercicio.dart';
import '../models/registro_carga.dart';
import '../saude/progressao_carga.dart';
import '../services/treino_repository.dart';
import '../widgets/cronometro_descanso.dart';
import '../widgets/grafico_linha_simples.dart';

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

    final historico = await _carregarHistorico();
    final destaque = destaqueNovoRecorde(widget.exercicio.id, historico);
    if (destaque != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(destaque)));
    }

    if (!mounted) return;
    setState(() {
      _historicoFuture = Future.value(historico);
    });
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  String _kg(double v) =>
      '${v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1)} kg';

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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: _ImagemExercicio(
                caminho: exercicio.caminhoImagem ?? exercicio.grupoMuscularPrincipal.ilustracaoPadrao,
              ),
            ),
          ),
          if (exercicio.caminhoImagem == null) ...[
            const SizedBox(height: 4),
            Text(
              'Ilustração genérica do grupo muscular — imagem real do exercício em produção.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(exercicio.instrucoes, style: Theme.of(context).textTheme.bodyLarge),
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

              final registros = snapshot.data ?? const <RegistroCarga>[];
              final historico = registros.reversed.toList();
              if (historico.isEmpty) {
                return const Text('Nenhum registro de carga ainda para este exercício.');
              }

              final evolucao = resumirEvolucao(widget.exercicio.id, registros);

              return Column(
                key: const Key('lista-historico-carga'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (evolucao != null) ...[
                    GraficoLinhaSimples(valores: evolucao.pesos, altura: 100),
                    const SizedBox(height: 8),
                    Text(
                      evolucao.progrediu
                          ? 'De ${_kg(evolucao.pesoInicial)} para ${_kg(evolucao.pesoAtual)} '
                                'em ${evolucao.semanas} semana(s).'
                          : 'Carga estável em ${_kg(evolucao.pesoAtual)} — '
                                'quando se sentir pronta, tente subir um pouco.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Divider(height: 24),
                  ],
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

/// Renderiza um asset de imagem do exercício, escolhendo entre SVG
/// (ilustrações genéricas por grupo muscular) e raster (futuras imagens
/// reais geradas por IA) conforme a extensão do arquivo.
class _ImagemExercicio extends StatelessWidget {
  const _ImagemExercicio({required this.caminho});

  final String caminho;

  @override
  Widget build(BuildContext context) {
    if (caminho.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(caminho, fit: BoxFit.contain);
    }
    return Image.asset(
      caminho,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
