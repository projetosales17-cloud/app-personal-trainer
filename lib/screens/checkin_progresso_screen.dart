import 'package:flutter/material.dart';

import '../models/checkin_progresso.dart';
import '../models/estrategia_bloco.dart';
import '../services/programa_treino_repository.dart';

/// Questionário de progresso do fim de bloco (~6 semanas). As respostas
/// definem a estratégia da próxima ficha (ver `EstrategiaBloco`) e o peso /
/// as medidas informadas vão para a aba Progresso.
class CheckinProgressoScreen extends StatefulWidget {
  CheckinProgressoScreen({
    super.key,
    required this.blocoConcluido,
    ProgramaTreinoRepository? programaRepositorio,
    this.pesoSugerido,
  }) : programaRepositorio = programaRepositorio ?? ProgramaTreinoRepository();

  final int blocoConcluido;
  final ProgramaTreinoRepository programaRepositorio;
  final double? pesoSugerido;

  @override
  State<CheckinProgressoScreen> createState() => _CheckinProgressoScreenState();
}

class _CheckinProgressoScreenState extends State<CheckinProgressoScreen> {
  late final _pesoController = TextEditingController(
    text: widget.pesoSugerido != null ? _numero(widget.pesoSugerido!) : '',
  );
  final _cinturaController = TextEditingController();
  final _quadrilController = TextEditingController();
  final _bracoController = TextEditingController();
  final _coxaController = TextEditingController();

  AderenciaPercebida? _aderencia;
  DificuldadeTreino? _dificuldade;
  Recuperacao? _recuperacao;
  bool _dorNova = false;
  String? _regiaoDor;
  bool _notaDiferenca = false;
  bool _objetivoMudou = false;
  bool _enviando = false;

  static String _numero(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  void dispose() {
    for (final c in [
      _pesoController,
      _cinturaController,
      _quadrilController,
      _bracoController,
      _coxaController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _podeEnviar =>
      _aderencia != null &&
      _dificuldade != null &&
      _recuperacao != null &&
      (!_dorNova || _regiaoDor != null);

  double? _parse(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));

  Future<void> _enviar() async {
    setState(() => _enviando = true);
    final checkin = CheckinProgresso(
      data: DateTime.now(),
      blocoConcluido: widget.blocoConcluido,
      aderencia: _aderencia!,
      dificuldade: _dificuldade!,
      recuperacao: _recuperacao!,
      dorNova: _dorNova,
      regiaoDorNova: _dorNova ? _regiaoDor : null,
      notaDiferenca: _notaDiferenca,
      objetivoMudou: _objetivoMudou,
      pesoKg: _parse(_pesoController),
      cinturaCm: _parse(_cinturaController),
      quadrilCm: _parse(_quadrilController),
      bracoCm: _parse(_bracoController),
      coxaCm: _parse(_coxaController),
    );

    final estrategia = await widget.programaRepositorio.registrarCheckin(checkin);
    if (!mounted) return;
    setState(() => _enviando = false);
    await _mostrarResultado(estrategia);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _mostrarResultado(EstrategiaBloco estrategia) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Bloco ${estrategia.bloco}: ${estrategia.faseNome}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(estrategia.mensagem),
            const SizedBox(height: 12),
            Text(
              'Sua nova ficha já está pronta nesta aba.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          FilledButton(
            key: const Key('botao-ver-nova-rutina'),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ver minha ficha'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-in de progresso')),
      body: SingleChildScrollView(
        key: const Key('lista-checkin-progresso'),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            'Você terminou o bloco ${widget.blocoConcluido}. Conta pra gente como foi '
            'pra montar a sua próxima ficha.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text('Peso e medidas', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            key: const Key('campo-peso-checkin'),
            controller: _pesoController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Peso atual (kg)'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cinturaController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Cintura (cm)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _quadrilController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Quadril (cm)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _bracoController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Braço (cm)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _coxaController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Coxa (cm)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _Pergunta<AderenciaPercebida>(
            titulo: 'Quanto você conseguiu treinar neste bloco?',
            valores: AderenciaPercebida.values,
            rotulo: (v) => v.label,
            selecionado: _aderencia,
            aoSelecionar: (v) => setState(() => _aderencia = v),
          ),
          _Pergunta<DificuldadeTreino>(
            titulo: 'Como o treino tem estado?',
            valores: DificuldadeTreino.values,
            rotulo: (v) => v.label,
            selecionado: _dificuldade,
            aoSelecionar: (v) => setState(() => _dificuldade = v),
          ),
          _Pergunta<Recuperacao>(
            titulo: 'Como você tem se sentido?',
            valores: Recuperacao.values,
            rotulo: (v) => v.label,
            selecionado: _recuperacao,
            aoSelecionar: (v) => setState(() => _recuperacao = v),
          ),
          SwitchListTile(
            key: const Key('switch-dor-nova'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Alguma dor ou desconforto novo?'),
            value: _dorNova,
            onChanged: (v) => setState(() {
              _dorNova = v;
              if (!v) _regiaoDor = null;
            }),
          ),
          if (_dorNova)
            DropdownButtonFormField<String>(
              key: const Key('dropdown-regiao-dor'),
              initialValue: _regiaoDor,
              decoration: const InputDecoration(labelText: 'Em qual região?'),
              items: [
                for (final r in regioesDorCheckin)
                  DropdownMenuItem(value: r, child: Text(r)),
              ],
              onChanged: (v) => setState(() => _regiaoDor = v),
            ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Já nota diferença no seu corpo?'),
            value: _notaDiferenca,
            onChanged: (v) => setState(() => _notaDiferenca = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Seu objetivo mudou?'),
            value: _objetivoMudou,
            onChanged: (v) => setState(() => _objetivoMudou = v),
          ),
          if (_objetivoMudou)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Depois deste check-in, atualize seu objetivo em '
                'Perfil > Editar meus dados.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('botao-enviar-checkin'),
            onPressed: _podeEnviar && !_enviando ? _enviar : null,
            child: _enviando
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Enviar e gerar nova ficha'),
          ),
          ],
        ),
      ),
    );
  }
}

class _Pergunta<T> extends StatelessWidget {
  const _Pergunta({
    required this.titulo,
    required this.valores,
    required this.rotulo,
    required this.selecionado,
    required this.aoSelecionar,
  });

  final String titulo;
  final List<T> valores;
  final String Function(T) rotulo;
  final T? selecionado;
  final ValueChanged<T> aoSelecionar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(titulo, style: Theme.of(context).textTheme.titleSmall),
        for (final v in valores)
          RadioListTile<T>(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(rotulo(v)),
            value: v,
            // ignore: deprecated_member_use
            groupValue: selecionado,
            // ignore: deprecated_member_use
            onChanged: (novo) => novo == null ? null : aoSelecionar(novo),
          ),
      ],
    );
  }
}
