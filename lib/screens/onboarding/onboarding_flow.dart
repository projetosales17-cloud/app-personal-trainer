import 'package:flutter/material.dart';

import '../../models/anamnese.dart';
import '../../saude/imc.dart';
import '../../saude/metabolismo.dart';
import '../../services/anamnese_repository.dart';

const _condicoesHormonais = [
  'Nenhuma',
  'Menopausa',
  'TPM / ciclo irregular',
  'SOP (Síndrome do Ovário Policístico)',
  'Outra',
];

const _restricoesComuns = [
  'Lactose',
  'Glúten',
  'Vegetariana',
  'Vegana',
  'Diabetes',
];

const _lesoesComuns = [
  'Joelho',
  'Ombro',
  'Coluna/lombar',
  'Punho',
  'Tornozelo',
];

const _regioesComuns = [
  'Aumentar glúteo',
  'Aumentar pernas',
  'Diminuir braço',
  'Diminuir abdômen',
  'Fortalecer core',
];

/// Fluxo de onboarding da anamnese, em etapas. A conta (e-mail/senha) já
/// foi criada antes disso, nas telas de login/cadastro — ver
/// AutenticacaoGate. Ao concluir, salva a anamnese localmente e chama
/// [onConcluido].
class OnboardingFlow extends StatefulWidget {
  OnboardingFlow({super.key, required this.onConcluido, AnamneseRepository? repositorio})
    : repositorio = repositorio ?? AnamneseRepository();

  final VoidCallback onConcluido;
  final AnamneseRepository repositorio;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int _passo = 0;
  static const _totalPassos = 11;

  final _idadeController = TextEditingController();
  final _alturaController = TextEditingController();
  final _pesoAtualController = TextEditingController();
  final _pesoDesejadoController = TextEditingController();
  final _tipoCirurgiaController = TextEditingController();
  final _mesesCirurgiaController = TextEditingController();
  final _condicaoOutraController = TextEditingController();
  final _restricaoOutraController = TextEditingController();
  final _lesaoOutraController = TextEditingController();

  Objetivo? _objetivo;
  bool _cirurgiaBariatrica = false;
  String _condicaoHormonal = _condicoesHormonais.first;
  final Set<String> _restricoes = {};
  final Set<String> _lesoes = {};
  NivelAtividade? _nivelAtividade;
  int _frequenciaSemanalDias = 3;
  LocalTreino? _localTreino;
  final Set<String> _regioes = {};

  bool _salvando = false;

  @override
  void dispose() {
    for (final controller in [
      _idadeController,
      _alturaController,
      _pesoAtualController,
      _pesoDesejadoController,
      _tipoCirurgiaController,
      _mesesCirurgiaController,
      _condicaoOutraController,
      _restricaoOutraController,
      _lesaoOutraController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _podeAvancar => switch (_passo) {
    1 =>
      double.tryParse(_idadeController.text.replaceAll(',', '.')) != null &&
          double.tryParse(_alturaController.text.replaceAll(',', '.')) != null &&
          double.tryParse(_pesoAtualController.text.replaceAll(',', '.')) != null,
    2 => _objetivo != null,
    3 =>
      !_cirurgiaBariatrica ||
          (_tipoCirurgiaController.text.trim().isNotEmpty &&
              int.tryParse(_mesesCirurgiaController.text) != null),
    7 => _nivelAtividade != null,
    8 => _localTreino != null,
    _ => true,
  };

  void _avancar() {
    if (_passo == _totalPassos - 1) {
      _concluir();
      return;
    }
    setState(() => _passo++);
  }

  void _voltar() {
    if (_passo == 0) return;
    setState(() => _passo--);
  }

  Future<void> _concluir() async {
    setState(() => _salvando = true);

    final anamnese = Anamnese(
      idade: int.parse(_idadeController.text),
      alturaCm: double.parse(_alturaController.text.replaceAll(',', '.')),
      pesoAtualKg: double.parse(_pesoAtualController.text.replaceAll(',', '.')),
      pesoDesejadoKg: double.tryParse(_pesoDesejadoController.text.replaceAll(',', '.')),
      objetivoPrincipal: _objetivo!,
      cirurgiaBariatrica: _cirurgiaBariatrica,
      tipoCirurgiaBariatrica: _cirurgiaBariatrica ? _tipoCirurgiaController.text.trim() : null,
      mesesDesdeCirurgia:
          _cirurgiaBariatrica ? int.tryParse(_mesesCirurgiaController.text) : null,
      condicaoHormonal:
          _condicaoHormonal == 'Outra' ? _condicaoOutraController.text.trim() : _condicaoHormonal,
      restricoesAlimentares: [
        ..._restricoes,
        if (_restricaoOutraController.text.trim().isNotEmpty) _restricaoOutraController.text.trim(),
      ],
      lesoesLimitacoes: [
        ..._lesoes,
        if (_lesaoOutraController.text.trim().isNotEmpty) _lesaoOutraController.text.trim(),
      ],
      nivelAtividade: _nivelAtividade!,
      frequenciaSemanalDias: _frequenciaSemanalDias,
      regioesPriorizadas: _regioes.toList(),
      localTreino: _localTreino!,
    );

    await widget.repositorio.salvar(anamnese);
    if (!mounted) return;
    widget.onConcluido();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(value: (_passo + 1) / _totalPassos),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(child: _conteudoDoPasso()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  if (_passo > 0)
                    TextButton(onPressed: _voltar, child: const Text('Voltar')),
                  const Spacer(),
                  FilledButton(
                    onPressed: _salvando || !_podeAvancar ? null : _avancar,
                    child: Text(_passo == _totalPassos - 1 ? 'Concluir' : 'Avançar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _conteudoDoPasso() {
    switch (_passo) {
      case 0:
        return const _TextoPasso(
          titulo: 'Bem-vinda!',
          texto:
              'Vamos configurar seu plano personalizado de treino e alimentação. '
              'Isso leva só alguns minutos.',
        );
      case 1:
        return _passoDadosBasicos();
      case 2:
        return _passoObjetivo();
      case 3:
        return _passoBariatrica();
      case 4:
        return _passoCondicaoHormonal();
      case 5:
        return _passoMultiSelecao(
          titulo: 'Restrições alimentares ou alergias',
          opcoes: _restricoesComuns,
          selecionadas: _restricoes,
          outroController: _restricaoOutraController,
        );
      case 6:
        return _passoMultiSelecao(
          titulo: 'Lesões ou limitações físicas',
          opcoes: _lesoesComuns,
          selecionadas: _lesoes,
          outroController: _lesaoOutraController,
        );
      case 7:
        return _passoAtividade();
      case 8:
        return _passoLocalTreino();
      case 9:
        return _passoMultiSelecao(
          titulo: 'Priorização de região corporal',
          opcoes: _regioesComuns,
          selecionadas: _regioes,
          outroController: null,
        );
      case 10:
        return _passoResumo();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _passoDadosBasicos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dados básicos', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        TextField(
          controller: _idadeController,
          decoration: const InputDecoration(labelText: 'Idade (anos)'),
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _alturaController,
          decoration: const InputDecoration(labelText: 'Altura (cm)'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _pesoAtualController,
          decoration: const InputDecoration(labelText: 'Peso atual (kg)'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _pesoDesejadoController,
          decoration: const InputDecoration(labelText: 'Peso desejado (kg) — opcional'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }

  Widget _passoObjetivo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Qual seu objetivo principal?', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        for (final opcao in Objetivo.values)
          RadioListTile<Objetivo>(
            contentPadding: EdgeInsets.zero,
            title: Text(opcao.label),
            value: opcao,
            // ignore: deprecated_member_use
            groupValue: _objetivo,
            // ignore: deprecated_member_use
            onChanged: (valor) => setState(() => _objetivo = valor),
          ),
      ],
    );
  }

  Widget _passoBariatrica() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Já fez cirurgia bariátrica?', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Sim'),
          value: _cirurgiaBariatrica,
          onChanged: (valor) => setState(() => _cirurgiaBariatrica = valor),
        ),
        if (_cirurgiaBariatrica) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _tipoCirurgiaController,
            decoration: const InputDecoration(labelText: 'Tipo de cirurgia'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _mesesCirurgiaController,
            decoration: const InputDecoration(labelText: 'Meses desde a cirurgia'),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ],
    );
  }

  Widget _passoCondicaoHormonal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Condição hormonal', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        for (final opcao in _condicoesHormonais)
          RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            title: Text(opcao),
            value: opcao,
            // ignore: deprecated_member_use
            groupValue: _condicaoHormonal,
            // ignore: deprecated_member_use
            onChanged: (valor) => setState(() => _condicaoHormonal = valor!),
          ),
        if (_condicaoHormonal == 'Outra')
          TextField(
            controller: _condicaoOutraController,
            decoration: const InputDecoration(labelText: 'Qual?'),
          ),
      ],
    );
  }

  Widget _passoMultiSelecao({
    required String titulo,
    required List<String> opcoes,
    required Set<String> selecionadas,
    required TextEditingController? outroController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final opcao in opcoes)
              FilterChip(
                label: Text(opcao),
                selected: selecionadas.contains(opcao),
                onSelected: (selecionado) => setState(() {
                  if (selecionado) {
                    selecionadas.add(opcao);
                  } else {
                    selecionadas.remove(opcao);
                  }
                }),
              ),
          ],
        ),
        if (outroController != null) ...[
          const SizedBox(height: 12),
          TextField(
            controller: outroController,
            decoration: const InputDecoration(labelText: 'Outra (opcional)'),
          ),
        ],
      ],
    );
  }

  Widget _passoAtividade() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nível de atividade', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        for (final opcao in NivelAtividade.values)
          RadioListTile<NivelAtividade>(
            contentPadding: EdgeInsets.zero,
            title: Text(opcao.label),
            value: opcao,
            // ignore: deprecated_member_use
            groupValue: _nivelAtividade,
            // ignore: deprecated_member_use
            onChanged: (valor) => setState(() => _nivelAtividade = valor),
          ),
        const SizedBox(height: 16),
        Text('Dias disponíveis por semana: $_frequenciaSemanalDias'),
        Slider(
          value: _frequenciaSemanalDias.toDouble(),
          min: 1,
          max: 7,
          divisions: 6,
          label: '$_frequenciaSemanalDias',
          onChanged: (valor) => setState(() => _frequenciaSemanalDias = valor.round()),
        ),
      ],
    );
  }

  Widget _passoLocalTreino() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Onde você vai treinar?', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        for (final opcao in LocalTreino.values)
          RadioListTile<LocalTreino>(
            contentPadding: EdgeInsets.zero,
            title: Text(opcao.label),
            value: opcao,
            // ignore: deprecated_member_use
            groupValue: _localTreino,
            // ignore: deprecated_member_use
            onChanged: (valor) => setState(() => _localTreino = valor),
          ),
        const SizedBox(height: 8),
        Text(
          'Sua ficha será montada com exercícios equivalentes para o modo escolhido.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _passoResumo() {
    if (_salvando) {
      return const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final idade = int.parse(_idadeController.text);
    final alturaCm = double.parse(_alturaController.text.replaceAll(',', '.'));
    final pesoAtualKg = double.parse(_pesoAtualController.text.replaceAll(',', '.'));

    final imc = calcularImc(pesoAtualKg, alturaCm / 100);
    final classificacaoImc = classificarImc(imc);
    final alertaSaude = verificarAlertaSaude(imc);
    final tmb = calcularTmb(pesoAtualKg, alturaCm, idade, Sexo.feminino);
    final gastoCalorico = calcularGastoCaloricoDiario(tmb, _nivelAtividade!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resumo', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Text('Objetivo: ${_objetivo?.label ?? '-'}'),
        Text('Idade: $idade anos'),
        Text('Altura: $alturaCm cm'),
        Text('Peso atual: $pesoAtualKg kg'),
        Text('Nível de atividade: ${_nivelAtividade?.label ?? '-'}'),
        Text('Dias por semana: $_frequenciaSemanalDias'),
        Text('Local de treino: ${_localTreino?.label ?? '-'}'),
        const Divider(height: 32),
        Text('IMC: $imc ($classificacaoImc)'),
        Text('Taxa Metabólica Basal: $tmb kcal/dia'),
        Text('Gasto calórico diário estimado: $gastoCalorico kcal'),
        if (alertaSaude != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'ATENÇÃO: $alertaSaude',
              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
            ),
          ),
        ],
        const SizedBox(height: 16),
        const Text('Confirme para gerar seu plano inicial.'),
      ],
    );
  }
}

class _TextoPasso extends StatelessWidget {
  const _TextoPasso({required this.titulo, required this.texto});

  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Text(texto, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
