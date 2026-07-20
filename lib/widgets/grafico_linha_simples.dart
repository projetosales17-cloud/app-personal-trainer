import 'dart:math';

import 'package:flutter/material.dart';

/// Gráfico de linha minimalista para mostrar tendência ao longo do tempo
/// (ex: evolução de peso), sem dependência externa de gráficos.
class GraficoLinhaSimples extends StatelessWidget {
  const GraficoLinhaSimples({super.key, required this.valores, this.altura = 120});

  final List<double> valores;
  final double altura;

  @override
  Widget build(BuildContext context) {
    if (valores.length < 2) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      key: const Key('grafico-linha-simples'),
      height: altura,
      width: double.infinity,
      child: CustomPaint(
        painter: _LinhaPainter(valores: valores, cor: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class _LinhaPainter extends CustomPainter {
  _LinhaPainter({required this.valores, required this.cor});

  final List<double> valores;
  final Color cor;

  @override
  void paint(Canvas canvas, Size size) {
    final minimo = valores.reduce(min);
    final maximo = valores.reduce(max);
    final intervalo = (maximo - minimo).abs() < 0.001 ? 1.0 : maximo - minimo;

    final linha = Paint()
      ..color = cor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final ponto = Paint()..color = cor;

    final caminho = Path();
    for (var i = 0; i < valores.length; i++) {
      final x = size.width * i / (valores.length - 1);
      final normalizado = (valores[i] - minimo) / intervalo;
      final y = size.height - (normalizado * size.height);

      if (i == 0) {
        caminho.moveTo(x, y);
      } else {
        caminho.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 3, ponto);
    }
    canvas.drawPath(caminho, linha);
  }

  @override
  bool shouldRepaint(covariant _LinhaPainter oldDelegate) =>
      oldDelegate.valores != valores || oldDelegate.cor != cor;
}
