import 'dart:async';

import 'package:flutter/material.dart';

/// Cronômetro simples de descanso entre séries. Sem integração com
/// notificações ainda — só contagem visual (ver briefing do produto).
class CronometroDescanso extends StatefulWidget {
  const CronometroDescanso({super.key, this.duracaoInicial = const Duration(seconds: 60)});

  final Duration duracaoInicial;

  @override
  State<CronometroDescanso> createState() => _CronometroDescansoState();
}

class _CronometroDescansoState extends State<CronometroDescanso> {
  Timer? _timer;
  late Duration _restante = widget.duracaoInicial;
  bool _rodando = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _iniciar() {
    _timer?.cancel();
    setState(() {
      _restante = widget.duracaoInicial;
      _rodando = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restante.inSeconds <= 1) {
        timer.cancel();
        setState(() {
          _restante = Duration.zero;
          _rodando = false;
        });
      } else {
        setState(() => _restante -= const Duration(seconds: 1));
      }
    });
  }

  void _parar() {
    _timer?.cancel();
    setState(() {
      _rodando = false;
      _restante = widget.duracaoInicial;
    });
  }

  String _formatar(Duration duracao) {
    final minutos = duracao.inMinutes.toString().padLeft(2, '0');
    final segundos = (duracao.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutos:$segundos';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          _formatar(_restante),
          key: const Key('texto-cronometro'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(width: 16),
        if (_rodando)
          OutlinedButton(
            key: const Key('botao-parar-cronometro'),
            onPressed: _parar,
            child: const Text('Parar'),
          )
        else
          ElevatedButton(
            key: const Key('botao-iniciar-cronometro'),
            onPressed: _iniciar,
            child: const Text('Iniciar descanso'),
          ),
      ],
    );
  }
}
