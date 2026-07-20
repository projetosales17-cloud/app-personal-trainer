import 'package:flutter/material.dart';

import '../models/anamnese.dart';
import '../models/cardapio.dart';
import '../models/exercicio.dart';
import '../models/ficha_treino.dart';
import '../models/registro_peso.dart';
import '../services/anamnese_repository.dart';
import '../services/gerador_cardapio.dart';
import '../services/gerador_ficha_treino.dart';
import '../services/progresso_repository.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({
    super.key,
    AnamneseRepository? anamneseRepositorio,
    GeradorFichaTreino? geradorFicha,
    GeradorCardapio? geradorCardapio,
    ProgressoRepository? progressoRepositorio,
  }) : anamneseRepositorio = anamneseRepositorio ?? AnamneseRepository(),
       geradorFicha = geradorFicha ?? GeradorFichaTreino(),
       geradorCardapio = geradorCardapio ?? GeradorCardapio(),
       progressoRepositorio = progressoRepositorio ?? ProgressoRepository();

  final AnamneseRepository anamneseRepositorio;
  final GeradorFichaTreino geradorFicha;
  final GeradorCardapio geradorCardapio;
  final ProgressoRepository progressoRepositorio;

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
  late final Future<RegistroPeso?> _ultimoPesoFuture = widget.progressoRepositorio.ultimoPeso();

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
              FutureBuilder<RegistroPeso?>(
                future: _ultimoPesoFuture,
                builder: (context, pesoSnapshot) {
                  if (pesoSnapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _CardProgresso(anamnese: anamnese, ultimoRegistro: pesoSnapshot.data);
                },
              ),
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

class _CardProgresso extends StatelessWidget {
  const _CardProgresso({required this.anamnese, required this.ultimoRegistro});

  final Anamnese anamnese;
  final RegistroPeso? ultimoRegistro;

  @override
  Widget build(BuildContext context) {
    final ultimoRegistro = this.ultimoRegistro;
    final pesoAtual = ultimoRegistro?.pesoKg ?? anamnese.pesoAtualKg;
    final delta = pesoAtual - anamnese.pesoAtualKg;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progresso', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('${pesoAtual.toStringAsFixed(1)} kg', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            if (ultimoRegistro == null)
              const Text('Registre seu peso na aba Progresso para acompanhar a evolução.')
            else
              Text(
                delta == 0
                    ? 'Sem variação desde o início'
                    : '${delta > 0 ? '+' : ''}${delta.toStringAsFixed(1)} kg desde o início',
              ),
          ],
        ),
      ),
    );
  }
}
