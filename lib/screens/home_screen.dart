import 'package:flutter/material.dart';

import '../models/anamnese.dart';
import '../models/cardapio.dart';
import '../models/exercicio.dart';
import '../models/ficha_treino.dart';
import '../services/anamnese_repository.dart';
import '../services/gerador_cardapio.dart';
import '../services/gerador_ficha_treino.dart';

/// Card de Progresso ainda é placeholder — essa funcionalidade não foi
/// implementada (ver briefing do produto).
class HomeScreen extends StatefulWidget {
  HomeScreen({
    super.key,
    AnamneseRepository? anamneseRepositorio,
    GeradorFichaTreino? geradorFicha,
    GeradorCardapio? geradorCardapio,
  }) : anamneseRepositorio = anamneseRepositorio ?? AnamneseRepository(),
       geradorFicha = geradorFicha ?? GeradorFichaTreino(),
       geradorCardapio = geradorCardapio ?? GeradorCardapio();

  final AnamneseRepository anamneseRepositorio;
  final GeradorFichaTreino geradorFicha;
  final GeradorCardapio geradorCardapio;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

const _mensagensMotivacionais = [
  'Um treino de cada vez.',
  'Constância vale mais que intensidade.',
  'Você já chegou até aqui — continue.',
];

class _HomeScreenState extends State<HomeScreen> {
  late final Future<Anamnese?> _anamneseFuture = widget.anamneseRepositorio.carregar();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Início')),
      body: FutureBuilder<Anamnese?>(
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
                  'Complete a anamnese no onboarding para ver seu painel.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final ficha = widget.geradorFicha.gerar(anamnese);
          final cardapio = widget.geradorCardapio.gerar(anamnese);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Olá!', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                _mensagensMotivacionais[DateTime.now().day % _mensagensMotivacionais.length],
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              _CardTreinoDoDia(dia: ficha.dias.first, validaAte: ficha.validaAte),
              const SizedBox(height: 16),
              _CardAlimentacaoDoDia(dia: cardapio.dias.first, validaAte: cardapio.validaAte),
              const SizedBox(height: 16),
              const _CardPlaceholder(titulo: 'Progresso', descricao: 'Em breve.'),
            ],
          );
        },
      ),
    );
  }
}

String _formatarData(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year}';
}

class _CardTreinoDoDia extends StatelessWidget {
  const _CardTreinoDoDia({required this.dia, required this.validaAte});

  final DiaDeTreino dia;
  final DateTime validaAte;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Treino do dia', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final grupo in dia.gruposMusculares)
                  Chip(label: Text(grupo.label), visualDensity: VisualDensity.compact),
              ],
            ),
            const SizedBox(height: 8),
            Text('${dia.exercicios.length} exercícios · veja na aba Treino'),
            const SizedBox(height: 8),
            Text(
              'Ficha válida até ${_formatarData(validaAte)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _CardAlimentacaoDoDia extends StatelessWidget {
  const _CardAlimentacaoDoDia({required this.dia, required this.validaAte});

  final DiaDeCardapio dia;
  final DateTime validaAte;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alimentação do dia', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final refeicao in dia.refeicoes)
                  Chip(label: Text(refeicao.nome), visualDensity: VisualDensity.compact),
              ],
            ),
            const SizedBox(height: 8),
            Text('${dia.refeicoes.length} refeições · veja na aba Alimentação'),
            const SizedBox(height: 8),
            Text(
              'Cardápio válido até ${_formatarData(validaAte)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _CardPlaceholder extends StatelessWidget {
  const _CardPlaceholder({required this.titulo, required this.descricao});

  final String titulo;
  final String descricao;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(descricao),
          ],
        ),
      ),
    );
  }
}
