import 'package:flutter/material.dart';

import '../../models/anamnese.dart';
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
  static const _totalPassos = 14;

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
  final Set<String> _restricoes = {};
  final Set<String> _lesoes = {};
  bool _teveParto = false;
  DateTime? _dataParto;
  NivelAtividade? _nivelAtividade;
  int _frequenciaSemanalDias = 3;
  LocalTreino? _localTreino;
  PreferenciaTreino? _preferenciaTreino;
  final Set<String> _regioes = {};

  bool _salvando = false;

  bool get _semCicloMenstrual => _condicoesSemCiclo.contains(_condicaoHormonal);

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
    });
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
          _condicaoHormonal == 'Otra' ? _condicaoOutraController.text.trim() : _condicaoHormonal,
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
      preferenciaTreino: _preferenciaTreino!,
      dataParto: _teveParto ? _dataParto : null,
      cicloMenstrualRegular: _semCicloMenstrual ? false : _cicloMenstrualRegular,
      dataUltimaMenstruacao:
          (!_semCicloMenstrual && _cicloMenstrualRegular) ? _dataUltimaMenstruacao : null,
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
                    TextButton(onPressed: _voltar, child: const Text('Atrás')),
                  const Spacer(),
                  FilledButton(
                    onPressed: _salvando || !_podeAvancar ? null : _avancar,
                    child: Text(_passo == _totalPassos - 1 ? 'Finalizar' : 'Siguiente'),
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
          titulo: '¡Bienvenida!',
          texto:
              'Vamos a configurar tu plan personalizado de entrenamiento y alimentación. '
              'Esto toma solo unos minutos.',
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
        return _passoCicloMenstrual();
      case 6:
        return _passoMultiSelecao(
          titulo: 'Restricciones alimentarias o alergias',
          opcoes: _restricoesComuns,
          selecionadas: _restricoes,
          outroController: _restricaoOutraController,
        );
      case 7:
        return _passoMultiSelecao(
          titulo: 'Lesiones o limitaciones físicas',
          opcoes: _lesoesComuns,
          selecionadas: _lesoes,
          outroController: _lesaoOutraController,
        );
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

  Widget _passoDadosBasicos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Datos básicos', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        TextField(
          controller: _idadeController,
          decoration: const InputDecoration(labelText: 'Edad (años)'),
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
          decoration: const InputDecoration(labelText: 'Peso actual (kg)'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _pesoDesejadoController,
          decoration: const InputDecoration(labelText: 'Peso deseado (kg) — opcional'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              final selecionada = await showDatePicker(
                context: context,
                initialDate: _dataUltimaMenstruacao ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 60)),
                lastDate: DateTime.now(),
              );
              if (selecionada != null) {
                setState(() => _dataUltimaMenstruacao = selecionada);
              }
            },
          ),
        ],
      ],
    );
  }

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
              final selecionada = await showDatePicker(
                context: context,
                initialDate: _dataParto ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
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
        const Text('Confirma para generar tu plan inicial.'),
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
