import 'package:flutter/material.dart';

import '../models/anamnese.dart';
import '../models/cardapio.dart';
import '../services/anamnese_repository.dart';
import '../services/gerador_cardapio.dart';

class MeuCardapioView extends StatefulWidget {
  MeuCardapioView({
    super.key,
    AnamneseRepository? anamneseRepositorio,
    GeradorCardapio? gerador,
  }) : anamneseRepositorio = anamneseRepositorio ?? AnamneseRepository(),
       gerador = gerador ?? GeradorCardapio();

  final AnamneseRepository anamneseRepositorio;
  final GeradorCardapio gerador;

  @override
  State<MeuCardapioView> createState() => _MeuCardapioViewState();
}

class _MeuCardapioViewState extends State<MeuCardapioView> {
  late final Future<Anamnese?> _anamneseFuture = widget.anamneseRepositorio.carregar();

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Anamnese?>(
      future: _anamneseFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final anamnese = snapshot.data;
        if (anamnese == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Complete a anamnese no onboarding para gerar seu cardápio.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final cardapio = widget.gerador.gerar(anamnese);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Válido até ${_formatarData(cardapio.validaAte)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (anamnese.cirurgiaBariatrica) ...[
              const SizedBox(height: 8),
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Após cirurgia bariátrica suas necessidades nutricionais são '
                    'específicas. Este cardápio é uma sugestão geral e não '
                    'substitui a orientação de um(a) nutricionista.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
            if (cardapio.observacaoCiclo != null) ...[
              const SizedBox(height: 8),
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    cardapio.observacaoCiclo!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
            for (final observacao in cardapio.observacoesFoco) ...[
              const SizedBox(height: 8),
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    observacao,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            for (final dia in cardapio.dias) _DiaDeCardapioCard(dia: dia),
          ],
        );
      },
    );
  }
}

class _DiaDeCardapioCard extends StatelessWidget {
  const _DiaDeCardapioCard({required this.dia});

  final DiaDeCardapio dia;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dia ${dia.dia}', style: Theme.of(context).textTheme.titleMedium),
            const Divider(height: 24),
            for (final refeicao in dia.refeicoes) _RefeicaoTile(refeicao: refeicao),
          ],
        ),
      ),
    );
  }
}

class _RefeicaoTile extends StatelessWidget {
  const _RefeicaoTile({required this.refeicao});

  final RefeicaoDoDia refeicao;

  @override
  Widget build(BuildContext context) {
    final estiloPorcao = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(refeicao.nome, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          for (final alimento in refeicao.alimentos)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  '),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: alimento.nome,
                        children: [
                          TextSpan(
                            text: '  —  ${alimento.porcaoSugerida}',
                            style: estiloPorcao,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
