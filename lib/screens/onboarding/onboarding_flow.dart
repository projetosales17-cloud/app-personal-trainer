import 'package:flutter/material.dart';

import '../../models/anamnese.dart';
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

/// Fluxo completo de onboarding: boas-vindas, licença, conta e anamnese em
/// etapas. Ao concluir, salva a anamnese localmente e chama [onConcluido].
///
/// Licença e conta ainda não têm backend — os dados são só coletados na UI
/// por enquanto (ver decisão pendente de stack de backend/autenticação).
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
  static const _totalPassos = 12;

  final _licencaController = TextEditingController();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _idadeController = TextEditingController();
  final _alturaController = TextEditingController();
  final _pesoAtualController = TextEditingController();
  final _pesoDesejadoController = TextEditingController();
  final _tipoCirurgiaController = TextEditingController();
  final _mesesCirurgiaController = TextEditingController();
  final _condicaoOutraController = TextEditingController();
  final _restricaoOutraController = TextEditingController();
  final _lesaoOutraController = TextEditingController();

  bool _aceiteTermos = false;
  Objetivo? _objetivo;
  bool _cirurgiaBariatrica = false;
  String _condicaoHormonal = _condicoesHormonais.first;
  final Set<String> _restricoes = {};
  final Set<String> _lesoes = {};
  NivelAtividade? _nivelAtividade;
  int _frequenciaSemanalDias = 3;
  final Set<String> _regioes = {};

  bool _salvando = false;

  @override
  void dispose() {
    for (final controller in [
      _licencaController,
      _nomeController,
      _emailController,
      _senhaController,
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
    1 => _licencaController.text.trim().isNotEmpty,
    2 =>
      _nomeController.text.trim().isNotEmpty &&
          RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_emailController.text.trim()) &&
          _senhaController.text.length >= 6 &&
          _aceiteTermos,
    3 =>
      double.tryParse(_idadeController.text.replaceAll(',', '.')) != null &&
          double.tryParse(_alturaController.text.replaceAll(',', '.')) != null &&
          double.tryParse(_pesoAtualController.text.replaceAll(',', '.')) != null,
    4 => _objetivo != null,
    5 =>
      !_cirurgiaBariatrica ||
          (_tipoCirurgiaController.text.trim().isNotEmpty &&
              int.tryParse(_mesesCirurgiaController.text) != null),
    9 => _nivelAtividade != null,
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
        return _CampoTexto(
          titulo: 'Licença',
          label: 'Chave de licença',
          controller: _licencaController,
          onChanged: (_) => setState(() {}),
        );
      case 2:
        return _passoConta();
      case 3:
        return _passoDadosBasicos();
      case 4:
        return _passoObjetivo();
      case 5:
        return _passoBariatrica();
      case 6:
        return _passoCondicaoHormonal();
      case 7:
        return _passoMultiSelecao(
          titulo: 'Restrições alimentares ou alergias',
          opcoes: _restricoesComuns,
          selecionadas: _restricoes,
          outroController: _restricaoOutraController,
        );
      case 8:
        return _passoMultiSelecao(
          titulo: 'Lesões ou limitações físicas',
          opcoes: _lesoesComuns,
          selecionadas: _lesoes,
          outroController: _lesaoOutraController,
        );
      case 9:
        return _passoAtividade();
      case 10:
        return _passoMultiSelecao(
          titulo: 'Priorização de região corporal',
          opcoes: _regioesComuns,
          selecionadas: _regioes,
          outroController: null,
        );
      case 11:
        return _passoResumo();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _passoConta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Crie sua conta', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        TextField(
          controller: _nomeController,
          decoration: const InputDecoration(labelText: 'Nome'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'E-mail'),
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _senhaController,
          decoration: const InputDecoration(labelText: 'Senha (mín. 6 caracteres)'),
          obscureText: true,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: _aceiteTermos,
          onChanged: (valor) => setState(() => _aceiteTermos = valor ?? false),
          title: const Text('Li e aceito os termos de uso e a política de privacidade'),
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
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

  Widget _passoResumo() {
    if (_salvando) {
      return const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resumo', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Text('Objetivo: ${_objetivo?.label ?? '-'}'),
        Text('Idade: ${_idadeController.text}'),
        Text('Altura: ${_alturaController.text} cm'),
        Text('Peso atual: ${_pesoAtualController.text} kg'),
        Text('Nível de atividade: ${_nivelAtividade?.label ?? '-'}'),
        Text('Dias por semana: $_frequenciaSemanalDias'),
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

class _CampoTexto extends StatelessWidget {
  const _CampoTexto({
    required this.titulo,
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  final String titulo;
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
