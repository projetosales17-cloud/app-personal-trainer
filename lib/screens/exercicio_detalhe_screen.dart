import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/exercicio.dart';
import '../models/registro_carga.dart';
import '../saude/progressao_carga.dart';
import '../services/treino_repository.dart';
import '../widgets/cronometro_descanso.dart';
import 'imagem_ampliada_screen.dart';
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

  Future<void> _editarCarga(RegistroCarga registro) async {
    final editado = await showDialog<RegistroCarga>(
      context: context,
      builder: (_) => _DialogoEditarCarga(registro: registro),
    );
    if (editado == null) return;
    await widget.repositorio.atualizarCarga(editado);
    if (!mounted) return;
    setState(() {
      _historicoFuture = _carregarHistorico();
    });
  }

  Future<void> _apagarCarga(RegistroCarga registro) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar registro?'),
        content: Text(
          'El registro de ${_kg(registro.pesoKg)} · '
          '${registro.series}x${registro.repeticoes} '
          '(${_formatarData(registro.data)}) se eliminará.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const Key('confirmar-apagar-carga'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await widget.repositorio.removerCarga(registro.id);
    if (!mounted) return;
    setState(() {
      _historicoFuture = _carregarHistorico();
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
          Text('Cómo hacerlo', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _ImagemComZoom(
            caminho: exercicio.caminhoImagem ?? exercicio.grupoMuscularPrincipal.ilustracaoPadrao,
            titulo: exercicio.nome,
          ),
          if (exercicio.caminhoImagem == null) ...[
            const SizedBox(height: 4),
            Text(
              'Ilustración genérica del grupo muscular — imagen real del ejercicio en producción.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(exercicio.instrucoes, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          Text('Cronómetro de descanso', style: Theme.of(context).textTheme.titleMedium),
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
                  decoration: const InputDecoration(labelText: 'Series'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  key: const Key('campo-repeticoes'),
                  controller: _controladorRepeticoes,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Repeticiones'),
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
          Text('Historial', style: Theme.of(context).textTheme.titleMedium),
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
                return const Text('Aún no hay registros de carga para este ejercicio.');
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
                          ? 'De ${_kg(evolucao.pesoInicial)} a ${_kg(evolucao.pesoAtual)} '
                                'en ${evolucao.semanas} semana(s).'
                          : 'Carga estable en ${_kg(evolucao.pesoAtual)} — '
                                'cuando te sientas lista, intenta subir un poco.',
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
                      trailing: PopupMenuButton<String>(
                        key: Key('menu-carga-${registro.id}'),
                        onSelected: (opcao) {
                          if (opcao == 'editar') _editarCarga(registro);
                          if (opcao == 'apagar') _apagarCarga(registro);
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'editar', child: Text('Editar')),
                          PopupMenuItem(value: 'apagar', child: Text('Borrar')),
                        ],
                      ),
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

/// A imagem do exercício na tela de detalhe: mostra pequena e, ao tocar,
/// abre em tela cheia com zoom (pinça) — importante para quem precisa
/// ampliar para enxergar bem o movimento.
class _ImagemComZoom extends StatelessWidget {
  const _ImagemComZoom({required this.caminho, required this.titulo});

  final String caminho;
  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          key: const Key('imagem-exercicio-tocavel'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ImagemAmpliadaScreen(
                imagem: _ImagemExercicio(caminho: caminho),
                titulo: titulo,
              ),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: _ImagemExercicio(caminho: caminho),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.zoom_in, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              'Toca para ampliar',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
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

class _DialogoEditarCarga extends StatefulWidget {
  const _DialogoEditarCarga({required this.registro});

  final RegistroCarga registro;

  @override
  State<_DialogoEditarCarga> createState() => _DialogoEditarCargaState();
}

class _DialogoEditarCargaState extends State<_DialogoEditarCarga> {
  late final _peso = TextEditingController(
    text: widget.registro.pesoKg.toStringAsFixed(
      widget.registro.pesoKg == widget.registro.pesoKg.roundToDouble() ? 0 : 1,
    ),
  );
  late final _series = TextEditingController(text: widget.registro.series.toString());
  late final _repeticoes =
      TextEditingController(text: widget.registro.repeticoes.toString());

  @override
  void dispose() {
    _peso.dispose();
    _series.dispose();
    _repeticoes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar carga'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('editar-campo-peso-carga'),
            controller: _peso,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Peso (kg)'),
          ),
          TextField(
            key: const Key('editar-campo-series'),
            controller: _series,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Series'),
          ),
          TextField(
            key: const Key('editar-campo-repeticoes'),
            controller: _repeticoes,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Repeticiones'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const Key('editar-salvar-carga'),
          onPressed: () {
            final peso = double.tryParse(_peso.text.replaceAll(',', '.'));
            final series = int.tryParse(_series.text);
            final repeticoes = int.tryParse(_repeticoes.text);
            if (peso == null || series == null || repeticoes == null) return;
            if (peso < 0 || series <= 0 || repeticoes <= 0) return;
            Navigator.of(context).pop(
              widget.registro.copyWith(
                pesoKg: peso,
                series: series,
                repeticoes: repeticoes,
              ),
            );
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
