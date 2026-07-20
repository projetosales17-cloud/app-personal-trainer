import 'package:flutter/material.dart';

import '../models/anamnese.dart';
import '../services/anamnese_repository.dart';
import '../services/preferencias_repository.dart';

/// Assinatura/licença ainda depende de uma decisão de backend/autenticação
/// (ver briefing do produto) — por enquanto só um aviso. Central de suporte
/// também ainda não existe.
class PerfilScreen extends StatefulWidget {
  PerfilScreen({
    super.key,
    AnamneseRepository? anamneseRepositorio,
    PreferenciasRepository? preferenciasRepositorio,
  }) : anamneseRepositorio = anamneseRepositorio ?? AnamneseRepository(),
       preferenciasRepositorio = preferenciasRepositorio ?? PreferenciasRepository();

  final AnamneseRepository anamneseRepositorio;
  final PreferenciasRepository preferenciasRepositorio;

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late final Future<Anamnese?> _anamneseFuture = widget.anamneseRepositorio.carregar();
  late Future<bool> _notificacoesFuture = widget.preferenciasRepositorio.notificacoesAtivadas();

  Future<void> _alterarNotificacoes(bool ativado) async {
    await widget.preferenciasRepositorio.definirNotificacoesAtivadas(ativado);
    setState(() {
      _notificacoesFuture = widget.preferenciasRepositorio.notificacoesAtivadas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: FutureBuilder<Anamnese?>(
        future: _anamneseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final anamnese = snapshot.data;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Seus dados', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (anamnese == null)
                const Text('Complete a anamnese no onboarding para ver seus dados aqui.')
              else
                _CardDadosAnamnese(anamnese: anamnese),
              const SizedBox(height: 24),
              Text('Notificações', style: Theme.of(context).textTheme.titleMedium),
              FutureBuilder<bool>(
                future: _notificacoesFuture,
                builder: (context, notifSnapshot) {
                  if (notifSnapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return SwitchListTile(
                    key: const Key('switch-notificacoes'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Lembretes de treino e alimentação'),
                    value: notifSnapshot.data ?? true,
                    onChanged: _alterarNotificacoes,
                  );
                },
              ),
              const SizedBox(height: 24),
              Text('Assinatura e licença', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'A gestão de assinatura e licença ainda depende de uma decisão de '
                    'backend/autenticação e não está disponível nesta versão.',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Suporte', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Canal de suporte em breve.'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CardDadosAnamnese extends StatelessWidget {
  const _CardDadosAnamnese({required this.anamnese});

  final Anamnese anamnese;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _linha('Idade', '${anamnese.idade} anos'),
            _linha('Altura', '${anamnese.alturaCm.toStringAsFixed(0)} cm'),
            _linha('Peso atual', '${anamnese.pesoAtualKg.toStringAsFixed(1)} kg'),
            if (anamnese.pesoDesejadoKg != null)
              _linha('Peso desejado', '${anamnese.pesoDesejadoKg!.toStringAsFixed(1)} kg'),
            _linha('Objetivo principal', anamnese.objetivoPrincipal.label),
            _linha('Nível de atividade', anamnese.nivelAtividade.label),
            _linha('Frequência semanal', '${anamnese.frequenciaSemanalDias}x por semana'),
            if (anamnese.condicaoHormonal != 'Nenhuma')
              _linha('Condição hormonal', anamnese.condicaoHormonal),
            if (anamnese.restricoesAlimentares.isNotEmpty)
              _linha('Restrições alimentares', anamnese.restricoesAlimentares.join(', ')),
            if (anamnese.lesoesLimitacoes.isNotEmpty)
              _linha('Lesões/limitações', anamnese.lesoesLimitacoes.join(', ')),
          ],
        ),
      ),
    );
  }

  Widget _linha(String rotulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 160, child: Text(rotulo, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }
}
