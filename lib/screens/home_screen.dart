import 'package:flutter/material.dart';

import '../models/anamnese.dart';
import '../models/cardapio.dart';
import '../models/checkin_treino.dart';
import '../models/estrategia_bloco.dart';
import '../models/exercicio.dart';
import '../models/ficha_treino.dart';
import '../models/programa_treino.dart';
import '../models/registro_peso.dart';
import '../services/anamnese_repository.dart';
import '../services/checkin_treino_repository.dart';
import '../services/foto_perfil_repository.dart';
import '../services/gerador_cardapio.dart';
import '../services/gerador_ficha_treino.dart';
import '../services/motor_aderencia.dart';
import '../services/preferencias_repository.dart';
import '../services/programa_treino_repository.dart';
import '../services/progresso_repository.dart';
import '../widgets/avatar_perfil.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({
    super.key,
    AnamneseRepository? anamneseRepositorio,
    GeradorFichaTreino? geradorFicha,
    GeradorCardapio? geradorCardapio,
    ProgressoRepository? progressoRepositorio,
    ProgramaTreinoRepository? programaRepositorio,
    CheckinTreinoRepository? checkinRepositorio,
    PreferenciasRepository? preferenciasRepositorio,
    MotorAderencia? motorAderencia,
    FotoPerfilRepository? fotoPerfilRepositorio,
  }) : anamneseRepositorio = anamneseRepositorio ?? AnamneseRepository(),
       geradorFicha = geradorFicha ?? GeradorFichaTreino(),
       geradorCardapio = geradorCardapio ?? GeradorCardapio(),
       progressoRepositorio = progressoRepositorio ?? ProgressoRepository(),
       programaRepositorio = programaRepositorio ?? ProgramaTreinoRepository(),
       checkinRepositorio = checkinRepositorio ?? CheckinTreinoRepository(),
       preferenciasRepositorio = preferenciasRepositorio ?? PreferenciasRepository(),
       motorAderencia = motorAderencia ?? MotorAderencia(),
       fotoPerfilRepositorio = fotoPerfilRepositorio ?? FotoPerfilRepository();

  final AnamneseRepository anamneseRepositorio;
  final FotoPerfilRepository fotoPerfilRepositorio;
  final GeradorFichaTreino geradorFicha;
  final GeradorCardapio geradorCardapio;
  final ProgressoRepository progressoRepositorio;
  final ProgramaTreinoRepository programaRepositorio;
  final CheckinTreinoRepository checkinRepositorio;
  final PreferenciasRepository preferenciasRepositorio;
  final MotorAderencia motorAderencia;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Contexto do programa de longo prazo — os mesmos dados que a aba Minha
/// ficha usa pra montar a ficha, pra Home mostrar exatamente o mesmo
/// treino e a mesma contagem de semana.
class _ContextoPrograma {
  const _ContextoPrograma({
    required this.programa,
    required this.checkins,
    required this.diasDaSemana,
  });

  final ProgramaTreino programa;
  final List<CheckinTreino> checkins;
  final List<int>? diasDaSemana;
}

const _mensagensMotivacionais = [
  'Um treino de cada vez.',
  'Constância vale mais que intensidade.',
  'Você já chegou até aqui — continue.',
];

class _HomeScreenState extends State<HomeScreen> {
  late Future<Anamnese?> _anamneseFuture = widget.anamneseRepositorio.carregar();
  late final Future<String?> _fotoPerfilFuture = widget.fotoPerfilRepositorio.carregar();
  late final Future<RegistroPeso?> _ultimoPesoFuture = widget.progressoRepositorio.ultimoPeso();
  late final Future<_ContextoPrograma> _contextoFuture = _carregarContexto();

  Future<_ContextoPrograma> _carregarContexto() async {
    final programa = await widget.programaRepositorio.iniciarSeNecessario();
    final checkins = await widget.checkinRepositorio.listar();
    final diasDaSemana = await widget.preferenciasRepositorio.diasDaSemanaEscolhidos();
    return _ContextoPrograma(
      programa: programa,
      checkins: checkins,
      diasDaSemana: diasDaSemana,
    );
  }

  @override
  void initState() {
    super.initState();
    AnamneseRepository.revisao.addListener(_recarregarAnamnese);
  }

  @override
  void dispose() {
    AnamneseRepository.revisao.removeListener(_recarregarAnamnese);
    super.dispose();
  }

  void _recarregarAnamnese() {
    if (!mounted) return;
    setState(() {
      _anamneseFuture = widget.anamneseRepositorio.carregar();
    });
  }

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

          final cardapio = widget.geradorCardapio.gerar(anamnese);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FutureBuilder<String?>(
                    future: _fotoPerfilFuture,
                    builder: (context, fotoSnapshot) => AvatarPerfil(
                      dataUri: fotoSnapshot.data,
                      nome: anamnese.nome.isEmpty ? anamnese.nomeExibicao : anamnese.nome,
                      raio: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          anamnese.nomeExibicao.isEmpty
                              ? 'Olá!'
                              : 'Olá, ${anamnese.nomeExibicao}!',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _mensagensMotivacionais[
                              DateTime.now().day % _mensagensMotivacionais.length],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder<_ContextoPrograma>(
                future: _contextoFuture,
                builder: (context, ctxSnapshot) {
                  if (!ctxSnapshot.hasData) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }
                  final ctx = ctxSnapshot.data!;
                  final estrategia = calcularEstrategiaBloco(
                    bloco: ctx.programa.blocoAtual,
                    nivelLiberado: ctx.programa.nivelLiberado,
                    ultimoCheckin: ctx.programa.ultimoCheckin,
                  );
                  final aderencia = widget.motorAderencia.avaliar(
                    diasDaSemanaEsperados: ctx.diasDaSemana,
                    datasCheckin: [for (final c in ctx.checkins) c.data],
                  );
                  final ficha = widget.geradorFicha.gerar(
                    anamnese,
                    reduzirVolumeRetomada: aderencia.emAlerta,
                    estrategiaBloco: estrategia,
                  );
                  return _CardTreinoDoDia(
                    dia: ficha.dias.first,
                    validaAte: ficha.validaAte,
                    semana: ctx.programa.semanaAtual(),
                    faseNome: estrategia.faseNome,
                  );
                },
              ),
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
  const _CardTreinoDoDia({
    required this.dia,
    required this.validaAte,
    required this.semana,
    required this.faseNome,
  });

  final DiaDeTreino dia;
  final DateTime validaAte;
  final int semana;
  final String faseNome;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Treino do dia', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Semana $semana · $faseNome',
              style: Theme.of(context).textTheme.bodySmall,
            ),
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
