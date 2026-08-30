import 'package:flutter/material.dart';

import '../../models/anamnese.dart';
import '../../models/exercicio.dart' show GrupoMuscular, GrupoMuscularLabel;
import '../../saude/ciclo_hormonal.dart';
import '../../saude/imc.dart';
import '../../saude/metabolismo.dart';
import '../../services/anamnese_repository.dart';

const _condicoesHormonais = [
  'Ninguna',
  'Menopausia',
  'Histerectomía (no tengo útero)',
  'SPM / ciclo irregular',
  'SOP (Síndrome de Ovario Poliquístico)',
  'Otra',
];

/// Condições em que não faz sentido perguntar sobre fase do ciclo
/// menstrual — a etapa de ciclo se auto-pula nesses casos. Reportado no
/// QA: mulher sem útero (histerectomia) era forçada ao switch "meu ciclo
/// é regular" sem ter resposta honesta.
const _condicoesSemCiclo = {'Menopausia', 'Histerectomía (no tengo útero)'};

const _restricoesComuns = [
  'Lactosa',
  'Gluten',
  'Vegetariana',
  'Vegana',
  'Diabetes',
];

const _lesoesComuns = [
  'Rodilla',
  'Hombro',
  'Codo',
  'Columna/lumbar',
  'Muñeca',
  'Tobillo',
];

const _regioesComuns = [
  'Aumentar glúteo',
  'Aumentar piernas',
  'Reducir brazo',
  'Reducir abdomen',
  'Fortalecer el core',
];

/// Fluxo de onboarding da anamnese, em etapas. A conta (e-mail/senha) já
/// foi criada antes disso, nas telas de login/cadastro — ver
/// AutenticacaoGate. Ao concluir, salva a anamnese localmente e chama
/// [onConcluido].
///
/// Quando [anamneseInicial] é informada, o fluxo entra em **modo de
/// edição**: pré-preenche todos os campos com os dados já salvos, pula a
/// tela de boas-vindas, mostra uma AppBar com botão de voltar (cancela sem
/// salvar) e o botão final passa a ser "Guardar". Usado pela tela de
/// Perfil para deixar a usuária corrigir a anamnese depois do onboarding.
class OnboardingFlow extends StatefulWidget {
  OnboardingFlow({
    super.key,
    required this.onConcluido,
    AnamneseRepository? repositorio,
    this.anamneseInicial,
  }) : repositorio = repositorio ?? AnamneseRepository();

  final VoidCallback onConcluido;
  final AnamneseRepository repositorio;
  final Anamnese? anamneseInicial;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int _passo = 0;
  static const _totalPassos = 14;

  final _nomeController = TextEditingController();
  final _apelidoController = TextEditingController();
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
  bool _cicloMenstrualRegular = true;
  DateTime? _dataUltimaMenstruacao;
  // Duração média do ciclo escolhida nos chips. `null` + _duracaoCicloNaoSei
  // false = nada escolhido (usa 28 dias). _duracaoCicloNaoSei = true quando
  // a usuária marcou "não sei" de propósito.
  int? _duracaoCicloDias;
  bool _duracaoCicloNaoSei = false;
  final Set<String> _restricoes = {};
  final Set<String> _lesoes = {};
  // Grupos musculares que a usuária marcou para não treinar (GrupoMuscular.name).
  final Set<String> _gruposEvitar = {};
  bool _teveParto = false;
  DateTime? _dataParto;
  NivelAtividade? _nivelAtividade;
  int _frequenciaSemanalDias = 3;
  LocalTreino? _localTreino;
  PreferenciaTreino? _preferenciaTreino;
  final Set<String> _regioes = {};

  bool _salvando = false;

  bool get _semCicloMenstrual => _condicoesSemCiclo.contains(_condicaoHormonal);

  bool get _editando => widget.anamneseInicial != null;

  @override
  void initState() {
    super.initState();
    final inicial = widget.anamneseInicial;
    if (inicial == null) return;

    // Modo de edição: começa na etapa de nome (sem o texto de boas-vindas)
    // e pré-preenche tudo com o que já estava salvo.
    _passo = 0;
    _nomeController.text = inicial.nome;
    _apelidoController.text = inicial.apelido ?? '';
    _idadeController.text = inicial.idade.toString();
    _alturaController.text = _formatarNumero(inicial.alturaCm);
    _pesoAtualController.text = _formatarNumero(inicial.pesoAtualKg);
    if (inicial.pesoDesejadoKg != null) {
      _pesoDesejadoController.text = _formatarNumero(inicial.pesoDesejadoKg!);
    }
    _objetivo = inicial.objetivoPrincipal;
    _cirurgiaBariatrica = inicial.cirurgiaBariatrica;
    _tipoCirurgiaController.text = inicial.tipoCirurgiaBariatrica ?? '';
    _mesesCirurgiaController.text = inicial.mesesDesdeCirurgia?.toString() ?? '';
    if (_condicoesHormonais.contains(inicial.condicaoHormonal)) {
      _condicaoHormonal = inicial.condicaoHormonal;
    } else {
      _condicaoHormonal = 'Otra';
      _condicaoOutraController.text = inicial.condicaoHormonal;
    }
    _preencherSelecao(
      inicial.restricoesAlimentares,
      _restricoesComuns,
      _restricoes,
      _restricaoOutraController,
    );
    _preencherSelecao(inicial.lesoesLimitacoes, _lesoesComuns, _lesoes, _lesaoOutraController);
    _gruposEvitar.addAll(inicial.gruposEvitar);
    _regioes.addAll(inicial.regioesPriorizadas.where(_regioesComuns.contains));
    _nivelAtividade = inicial.nivelAtividade;
    _frequenciaSemanalDias = inicial.frequenciaSemanalDias;
    _localTreino = inicial.localTreino;
    _preferenciaTreino = inicial.preferenciaTreino;
    _teveParto = inicial.dataParto != null;
    _dataParto = inicial.dataParto;
    _cicloMenstrualRegular = inicial.cicloMenstrualRegular;
    _dataUltimaMenstruacao = inicial.dataUltimaMenstruacao;
    _duracaoCicloDias = inicial.duracaoCicloDias;
  }

  static String _formatarNumero(double valor) =>
      valor == valor.roundToDouble() ? valor.toStringAsFixed(0) : valor.toString();

  /// Divide uma lista salva (presets + textos livres) de volta nos chips
  /// pré-definidos e no campo "Otra".
  static void _preencherSelecao(
    List<String> valores,
    List<String> presets,
    Set<String> destino,
    TextEditingController outroController,
  ) {
    final extras = <String>[];
    for (final valor in valores) {
      if (presets.contains(valor)) {
        destino.add(valor);
      } else {
        extras.add(valor);
      }
    }
    if (extras.isNotEmpty) outroController.text = extras.join(', ');
  }

  @override
  void dispose() {
    for (final controller in [
      _nomeController,
      _apelidoController,
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

  /// Faixas de sanidade para os dados básicos — barram erros de digitação
  /// (ex: 7070 kg) que gerariam IMC/hidratação/calorias sem sentido no
  /// resto do app.
  static const _faixaIdade = (min: 12.0, max: 100.0);
  static const _faixaAltura = (min: 100.0, max: 250.0);
  static const _faixaPeso = (min: 30.0, max: 300.0);

  /// Devolve o número digitado só se estiver dentro da faixa; senão `null`.
  static double? _numeroNaFaixa(String texto, ({double min, double max}) faixa) {
    final valor = double.tryParse(texto.trim().replaceAll(',', '.'));
    if (valor == null || valor < faixa.min || valor > faixa.max) return null;
    return valor;
  }

  /// Mensagem de erro para um campo dos dados básicos: `null` quando vazio
  /// (ainda não preenchido) ou válido; texto quando fora da faixa.
  String? _erroCampo(String texto, ({double min, double max}) faixa, String unidade) {
    if (texto.trim().isEmpty) return null;
    if (_numeroNaFaixa(texto, faixa) != null) return null;
    return 'Ingresa un valor entre ${faixa.min.toStringAsFixed(0)} y '
        '${faixa.max.toStringAsFixed(0)} $unidade.';
  }

  bool get _podeAvancar => switch (_passo) {
    0 => _nomeController.text.trim().isNotEmpty,
    1 =>
      _numeroNaFaixa(_idadeController.text, _faixaIdade) != null &&
          _numeroNaFaixa(_alturaController.text, _faixaAltura) != null &&
          _numeroNaFaixa(_pesoAtualController.text, _faixaPeso) != null &&
          (_pesoDesejadoController.text.trim().isEmpty ||
              _numeroNaFaixa(_pesoDesejadoController.text, _faixaPeso) != null),
    2 => _objetivo != null,
    3 =>
      !_cirurgiaBariatrica ||
          (_tipoCirurgiaController.text.trim().isNotEmpty &&
              int.tryParse(_mesesCirurgiaController.text) != null),
    9 => _nivelAtividade != null,
    10 => _localTreino != null,
    11 => _preferenciaTreino != null,
    _ => true,
  };

  void _avancar() {
    if (_passo == _totalPassos - 1) {
      _concluir();
      return;
    }
    setState(() {
      _passo++;
      // Pré-seleciona o caminho recomendado pelo app para o objetivo já
      // escolhido — a usuária pode trocar antes de confirmar (ver briefing
      // do produto: "o app sempre orienta qual seria o caminho recomendado").
      if (_passo == 11 && _preferenciaTreino == null && _objetivo != null) {
        _preferenciaTreino = _objetivo!.preferenciaTreinoRecomendada;
      }
      // Objetivo "glúteos y piernas" já entra com essas regiões marcadas
      // (a usuária pode mudar) — é o que dá sentido ao objetivo.
      if (_passo == 12 && _regioes.isEmpty && _objetivo == Objetivo.gluteoPernas) {
        _regioes.addAll(['Aumentar glúteo', 'Aumentar piernas']);
      }
    });
  }

  void _voltar() {
    if (_passo == 0) return;
    setState(() => _passo--);
  }

  int get _idadeInformada =>
      double.parse(_idadeController.text.trim().replaceAll(',', '.')).round();

  Future<void> _concluir() async {
    setState(() => _salvando = true);

    final apelido = _apelidoController.text.trim();
    final anamnese = Anamnese(
      nome: _nomeController.text.trim(),
      apelido: apelido.isEmpty ? null : apelido,
      idade: _idadeInformada,
      alturaCm: double.parse(_alturaController.text.replaceAll(',', '.')),
      pesoAtualKg: double.parse(_pesoAtualController.text.replaceAll(',', '.')),
      pesoDesejadoKg: double.tryParse(_pesoDesejadoController.text.replaceAll(',', '.')),
      objetivoPrincipal: _objetivo!,
      cirurgiaBariatrica: _cirurgiaBariatrica,
      tipoCirurgiaBariatrica: _cirurgiaBariatrica ? _tipoCirurgiaController.text.trim() : null,
      mesesDesdeCirurgia:
          _cirurgiaBariatrica ? int.tryParse(_mesesCirurgiaController.text) : null,
      condicaoHormonal:
          _condicaoHormonal == 'Otra' ? _condicaoOutraController.text.trim() : _condicaoHormonal,
      restricoesAlimentares: [
        ..._restricoes,
        if (_restricaoOutraController.text.trim().isNotEmpty) _restricaoOutraController.text.trim(),
      ],
      lesoesLimitacoes: [
        ..._lesoes,
        if (_lesaoOutraController.text.trim().isNotEmpty) _lesaoOutraController.text.trim(),
      ],
      gruposEvitar: _gruposEvitar.toList(),
      nivelAtividade: _nivelAtividade!,
      frequenciaSemanalDias: _frequenciaSemanalDias,
      regioesPriorizadas: _regioes.toList(),
      localTreino: _localTreino!,
      preferenciaTreino: _preferenciaTreino!,
      dataParto: _teveParto ? _dataParto : null,
      cicloMenstrualRegular: _semCicloMenstrual ? false : _cicloMenstrualRegular,
      dataUltimaMenstruacao:
          (!_semCicloMenstrual && _cicloMenstrualRegular) ? _dataUltimaMenstruacao : null,
      duracaoCicloDias:
          (!_semCicloMenstrual && _cicloMenstrualRegular) ? _duracaoCicloDias : null,
    );

    await widget.repositorio.salvar(anamnese);
    if (!mounted) return;
    widget.onConcluido();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _editando ? AppBar(title: const Text('Editar mis datos')) : null,
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
                    TextButton(onPressed: _voltar, child: const Text('Atrás')),
                  const Spacer(),
                  FilledButton(
                    onPressed: _salvando || !_podeAvancar ? null : _avancar,
                    child: Text(
                      _passo == _totalPassos - 1
                          ? (_editando ? 'Guardar' : 'Finalizar')
                          : 'Siguiente',
                    ),
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
        return _passoBoasVindas();
      case 1:
        return _passoDadosBasicos();
      case 2:
        return _passoObjetivo();
      case 3:
        return _passoBariatrica();
      case 4:
        return _passoCondicaoHormonal();
      case 5:
        return _passoCicloMenstrual();
      case 6:
        return _passoMultiSelecao(
          titulo: 'Restricciones alimentarias o alergias',
          opcoes: _restricoesComuns,
          selecionadas: _restricoes,
          outroController: _restricaoOutraController,
        );
      case 7:
        return _passoLesoesLimitacoes();
      case 8:
        return _passoPosParto();
      case 9:
        return _passoAtividade();
      case 10:
        return _passoLocalTreino();
      case 11:
        return _passoPreferenciaTreino();
      case 12:
        return _passoMultiSelecao(
          titulo: 'Priorización de zona corporal',
          opcoes: _regioesComuns,
          selecionadas: _regioes,
          outroController: null,
        );
      case 13:
        return _passoResumo();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _passoBoasVindas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_editando) ...[
          Text('¡Bienvenida!', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text(
            'Vamos a configurar tu plan personalizado de entrenamiento y alimentación. '
            'Primero, ¿cómo te llamas?',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
        ] else
          Text('Tu nombre', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        TextField(
          key: const Key('campo-nome-onboarding'),
          controller: _nomeController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Nombre'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('campo-apelido-onboarding'),
          controller: _apelidoController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Apodo — opcional',
            helperText: 'Así te va a saludar la app.',
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _passoDadosBasicos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Datos básicos', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        TextField(
          controller: _idadeController,
          decoration: InputDecoration(
            labelText: 'Edad (años)',
            errorText: _erroCampo(_idadeController.text, _faixaIdade, 'años'),
          ),
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _alturaController,
          decoration: InputDecoration(
            labelText: 'Altura (cm)',
            errorText: _erroCampo(_alturaController.text, _faixaAltura, 'cm'),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _pesoAtualController,
          decoration: InputDecoration(
            labelText: 'Peso actual (kg)',
            errorText: _erroCampo(_pesoAtualController.text, _faixaPeso, 'kg'),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _pesoDesejadoController,
          decoration: InputDecoration(
            labelText: 'Peso deseado (kg) — opcional',
            errorText: _erroCampo(_pesoDesejadoController.text, _faixaPeso, 'kg'),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _passoObjetivo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('¿Cuál es tu objetivo principal?', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        for (final opcao in Objetivo.values)
          RadioListTile<Objetivo>(
            contentPadding: EdgeInsets.zero,
            title: Text(opcao.label),
            subtitle: Text(opcao.descricao),
            isThreeLine: true,
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
        Text('¿Ya te hiciste una cirugía bariátrica?', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Sí'),
          value: _cirurgiaBariatrica,
          onChanged: (valor) => setState(() => _cirurgiaBariatrica = valor),
        ),
        if (_cirurgiaBariatrica) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _tipoCirurgiaController,
            decoration: const InputDecoration(labelText: 'Tipo de cirugía'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _mesesCirurgiaController,
            decoration: const InputDecoration(labelText: 'Meses desde la cirugía'),
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
        Text('Condición hormonal', style: Theme.of(context).textTheme.headlineSmall),
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
        if (_condicaoHormonal == 'Otra')
          TextField(
            controller: _condicaoOutraController,
            decoration: const InputDecoration(labelText: '¿Cuál?'),
          ),
      ],
    );
  }

  Widget _passoCicloMenstrual() {
    if (_semCicloMenstrual) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ciclo menstrual', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Como marcaste "$_condicaoHormonal" en el paso anterior, esta '
            'parte no aplica a tu perfil. Puedes continuar — tu plan de '
            'entrenamiento y alimentación no dependerá de la fase del ciclo.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ciclo menstrual (opcional)', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Usamos esto solo para ajustar el volumen del entrenamiento y dar '
          'consejos de alimentación según la fase del ciclo — puedes saltar '
          'este paso si no tiene sentido para ti (ej: menopausia o ciclo irregular).',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Mi ciclo es regular'),
          value: _cicloMenstrualRegular,
          onChanged: (valor) => setState(() => _cicloMenstrualRegular = valor),
        ),
        if (_cicloMenstrualRegular) ...[
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _dataUltimaMenstruacao == null
                  ? 'Fecha de la última menstruación'
                  : 'Última menstruación: ${_formatarData(_dataUltimaMenstruacao!)}',
            ),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: () async {
              final agora = DateTime.now();
              final primeiraData = agora.subtract(const Duration(days: 60));
              final selecionada = await showDatePicker(
                context: context,
                initialDate:
                    (_dataUltimaMenstruacao != null && _dataUltimaMenstruacao!.isAfter(primeiraData))
                    ? _dataUltimaMenstruacao!
                    : agora,
                firstDate: primeiraData,
                lastDate: agora,
              );
              if (selecionada != null) {
                setState(() => _dataUltimaMenstruacao = selecionada);
              }
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Duración promedio de tu ciclo',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            'Del 1er día de una menstruación al 1er día de la siguiente. '
            'Ayuda a que la estimación quede más exacta para ti.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              Widget chip(String rotulo, {required bool selecionado, required int? dias, required bool naoSei}) {
                return ChoiceChip(
                  label: Text(rotulo),
                  selected: selecionado,
                  onSelected: (_) => setState(() {
                    _duracaoCicloDias = dias;
                    _duracaoCicloNaoSei = naoSei;
                  }),
                );
              }

              return Wrap(
                spacing: 8,
                children: [
                  chip('~24 días', selecionado: _duracaoCicloDias == 24, dias: 24, naoSei: false),
                  chip('~28 días', selecionado: _duracaoCicloDias == 28, dias: 28, naoSei: false),
                  chip('~32 días', selecionado: _duracaoCicloDias == 32, dias: 32, naoSei: false),
                  chip('No sé', selecionado: _duracaoCicloNaoSei, dias: null, naoSei: true),
                ],
              );
            },
          ),
          if (_dataUltimaMenstruacao != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Según lo que indicaste, hoy estás en la fase '
                    '${_faseEstimada().label.toLowerCase()}.',
                    key: const Key('preview-fase-ciclo'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¿No parece correcto? Ajusta la fecha de arriba al primer '
                    'día de tu última menstruación.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }

  /// Fase estimada com os dados preenchidos até agora nesta etapa — usada
  /// só no preview da própria etapa. Assume que a data já foi informada.
  FaseCiclo _faseEstimada() => calcularFaseCiclo(
    _dataUltimaMenstruacao!,
    duracaoCiclo: _duracaoCicloDias ?? duracaoCicloDiasPadrao,
  );

  Widget _passoPosParto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Posparto (opcional)', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Si tuviste un parto reciente, la app evita ejercicios de abdomen '
          'por un tiempo, hasta que tengas el alta médica.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Tuve un parto reciente'),
          value: _teveParto,
          onChanged: (valor) => setState(() => _teveParto = valor),
        ),
        if (_teveParto) ...[
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _dataParto == null ? 'Fecha del parto' : 'Fecha del parto: ${_formatarData(_dataParto!)}',
            ),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: () async {
              final agora = DateTime.now();
              final primeiraData = agora.subtract(const Duration(days: 365));
              final selecionada = await showDatePicker(
                context: context,
                initialDate: (_dataParto != null && _dataParto!.isAfter(primeiraData))
                    ? _dataParto!
                    : agora,
                firstDate: primeiraData,
                lastDate: agora,
              );
              if (selecionada != null) {
                setState(() => _dataParto = selecionada);
              }
            },
          ),
        ],
      ],
    );
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  Widget _passoLesoesLimitacoes() {
    final texto = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lesiones o limitaciones físicas', style: texto.headlineSmall),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final opcao in _lesoesComuns)
              FilterChip(
                label: Text(opcao),
                selected: _lesoes.contains(opcao),
                onSelected: (sel) => setState(() {
                  sel ? _lesoes.add(opcao) : _lesoes.remove(opcao);
                }),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _lesaoOutraController,
          decoration: const InputDecoration(labelText: 'Otra (opcional)'),
        ),
        const SizedBox(height: 28),
        Text('Grupos que prefieres no entrenar', style: texto.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Marca si tienes lesión, recomendación médica, o simplemente no '
          'quieres entrenar ese grupo ahora. Tu entrenamiento se arma sin '
          'ellos — y puedes cambiarlo después en Perfil. ¿Hombro o codo '
          'lesionado? Conviene marcar también Pecho y Espalda, que jalan esas '
          'articulaciones.',
          style: texto.bodySmall,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final grupo in GrupoMuscular.values)
              FilterChip(
                key: Key('chip-evitar-${grupo.name}'),
                label: Text(grupo.label),
                selected: _gruposEvitar.contains(grupo.name),
                onSelected: (sel) => setState(() {
                  sel ? _gruposEvitar.add(grupo.name) : _gruposEvitar.remove(grupo.name);
                }),
              ),
          ],
        ),
        if (_gruposEvitar.length == GrupoMuscular.values.length) ...[
          const SizedBox(height: 8),
          Text(
            'Marcaste todos los grupos: tu entrenamiento quedará solo con '
            'cardio. Si no es la intención, desmarca alguno.',
            style: texto.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
        ],
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
            decoration: const InputDecoration(labelText: 'Otra (opcional)'),
          ),
        ],
      ],
    );
  }

  Widget _passoAtividade() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nivel de actividad', style: Theme.of(context).textTheme.headlineSmall),
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
        Text('Días disponibles por semana: $_frequenciaSemanalDias'),
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
        Text('¿Dónde vas a entrenar?', style: Theme.of(context).textTheme.headlineSmall),
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
          'Tu rutina se armará con ejercicios equivalentes para la modalidad elegida.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _passoPreferenciaTreino() {
    final recomendada = _objetivo?.preferenciaTreinoRecomendada;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('¿Pesas, cardio o ambos?', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        for (final opcao in PreferenciaTreino.values)
          RadioListTile<PreferenciaTreino>(
            contentPadding: EdgeInsets.zero,
            title: Text(opcao == recomendada ? '${opcao.label} (recomendado)' : opcao.label),
            value: opcao,
            // ignore: deprecated_member_use
            groupValue: _preferenciaTreino,
            // ignore: deprecated_member_use
            onChanged: (valor) => setState(() => _preferenciaTreino = valor),
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

    final idade = _idadeInformada;
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
        Text('Resumen', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Text('Objetivo: ${_objetivo?.label ?? '-'}'),
        Text('Edad: $idade años'),
        Text('Altura: $alturaCm cm'),
        Text('Peso actual: $pesoAtualKg kg'),
        Text('Nivel de actividad: ${_nivelAtividade?.label ?? '-'}'),
        Text('Días por semana: $_frequenciaSemanalDias'),
        Text('Lugar de entrenamiento: ${_localTreino?.label ?? '-'}'),
        Text('Preferencia: ${_preferenciaTreino?.label ?? '-'}'),
        if (_gruposEvitar.isNotEmpty)
          Text(
            'Sin entrenar: ${[
              for (final g in GrupoMuscular.values)
                if (_gruposEvitar.contains(g.name)) g.label,
            ].join(', ')}',
          ),
        const Divider(height: 32),
        Text('IMC: $imc ($classificacaoImc)'),
        Text('Tasa Metabólica Basal: $tmb kcal/día'),
        Text('Gasto calórico diario estimado: $gastoCalorico kcal'),
        if (alertaSaude != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'ATENCIÓN: $alertaSaude',
              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          _editando
              ? 'Guarda para actualizar tu plan con estos datos.'
              : 'Confirma para generar tu plan inicial.',
        ),
      ],
    );
  }
}
