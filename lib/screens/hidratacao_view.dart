import 'package:flutter/material.dart';

import '../models/anamnese.dart';
import '../saude/hidratacao.dart';
import '../services/anamnese_repository.dart';

/// Calculadora interativa de hidratação: a usuária ajusta peso, nível de
/// atividade e se o dia é quente / com treino longo, e a meta diária de
/// água atualiza na hora. Começa pré-preenchida com os dados da anamnese.
class HidratacaoView extends StatefulWidget {
  HidratacaoView({super.key, AnamneseRepository? repositorio})
    : repositorio = repositorio ?? AnamneseRepository();

  final AnamneseRepository repositorio;

  @override
  State<HidratacaoView> createState() => _HidratacaoViewState();
}

class _HidratacaoViewState extends State<HidratacaoView> {
  final _pesoController = TextEditingController();
  NivelAtividade _nivel = NivelAtividade.moderado;
  bool _diaQuente = false;
  bool _carregado = false;

  @override
  void initState() {
    super.initState();
    widget.repositorio.carregar().then((anamnese) {
      if (!mounted) return;
      setState(() {
        if (anamnese != null) {
          _pesoController.text = _numero(anamnese.pesoAtualKg);
          _nivel = anamnese.nivelAtividade;
        }
        _carregado = true;
      });
    });
  }

  static String _numero(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  void dispose() {
    _pesoController.dispose();
    super.dispose();
  }

  double? get _peso {
    final v = double.tryParse(_pesoController.text.trim().replaceAll(',', '.'));
    return (v != null && v > 0 && v <= 300) ? v : null;
  }

  @override
  Widget build(BuildContext context) {
    if (!_carregado) {
      return const Center(child: CircularProgressIndicator());
    }

    final peso = _peso;
    final metaMl = peso == null
        ? null
        : calcularHidratacaoDiaria(peso, _nivel, diaQuente: _diaQuente);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: Icon(
            Icons.local_drink,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            metaMl == null ? '—' : '${(metaMl / 1000).toStringAsFixed(1)} L por dia',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            metaMl == null
                ? 'Informe seu peso para calcular a meta.'
                : 'Cerca de ${(metaMl / 250).round()} copos de 250 ml ao longo do dia.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          key: const Key('campo-peso-hidratacion'),
          controller: _pesoController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Peso (kg)'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        Text('Nível de atividade', style: Theme.of(context).textTheme.titleSmall),
        for (final n in NivelAtividade.values)
          RadioListTile<NivelAtividade>(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(n.label),
            value: n,
            // ignore: deprecated_member_use
            groupValue: _nivel,
            // ignore: deprecated_member_use
            onChanged: (v) => setState(() => _nivel = v ?? _nivel),
          ),
        SwitchListTile(
          key: const Key('switch-dia-quente'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Dia quente ou treino longo hoje'),
          subtitle: const Text('Soma meio litro extra.'),
          value: _diaQuente,
          onChanged: (v) => setState(() => _diaQuente = v),
        ),
        const SizedBox(height: 8),
        Text(
          'Cálculo aproximado (35 ml por kg + ajuste por atividade e calor). '
          'A altura não influi na hidratação. Não substitui a orientação de '
          'um profissional de saúde.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
