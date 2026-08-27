import 'package:flutter/material.dart';

import '../models/anamnese.dart';
import 'onboarding/onboarding_flow.dart';
import '../services/anamnese_repository.dart';
import '../services/auth_repository.dart';
import '../services/gerador_ficha_treino.dart';
import '../services/notificacoes_treino_service.dart';
import '../services/preferencias_repository.dart';
import '../services/programa_treino_repository.dart';

/// Assinatura/pagamento ainda não está implementado (ver briefing do
/// produto) — conta e login já são reais (Firebase Authentication).
/// Central de suporte também ainda não existe.
class PerfilScreen extends StatefulWidget {
  PerfilScreen({
    super.key,
    AnamneseRepository? anamneseRepositorio,
    PreferenciasRepository? preferenciasRepositorio,
    GeradorFichaTreino? geradorFicha,
    NotificacoesTreinoService? notificacoesService,
    AuthRepository? authRepositorio,
    ProgramaTreinoRepository? programaRepositorio,
  }) : anamneseRepositorio = anamneseRepositorio ?? AnamneseRepository(),
       preferenciasRepositorio = preferenciasRepositorio ?? PreferenciasRepository(),
       geradorFicha = geradorFicha ?? GeradorFichaTreino(),
       notificacoesService = notificacoesService ?? NotificacoesTreinoService(),
       authRepositorio = authRepositorio ?? AuthRepository(),
       programaRepositorio = programaRepositorio ?? ProgramaTreinoRepository();

  final AnamneseRepository anamneseRepositorio;
  final PreferenciasRepository preferenciasRepositorio;
  final GeradorFichaTreino geradorFicha;
  final NotificacoesTreinoService notificacoesService;
  final AuthRepository authRepositorio;
  final ProgramaTreinoRepository programaRepositorio;

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late Future<Anamnese?> _anamneseFuture = widget.anamneseRepositorio.carregar();
  late Future<bool> _notificacoesFuture = widget.preferenciasRepositorio.notificacoesAtivadas();

  Future<void> _editarAnamnese(Anamnese anamnese) async {
    final atualizou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OnboardingFlow(
          repositorio: widget.anamneseRepositorio,
          anamneseInicial: anamnese,
          onConcluido: () => Navigator.of(context).pop(true),
        ),
      ),
    );
    if (atualizou == true && mounted) {
      setState(() {
        _anamneseFuture = widget.anamneseRepositorio.carregar();
      });
    }
  }

  Future<void> _recomecarPrograma() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Reiniciar tu programa?'),
        content: const Text(
          'Tu rutina vuelve a empezar desde la fase de adaptación (semana 1). '
          'Tu anamnesis y tu progreso registrado no se borran.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await widget.programaRepositorio.recomecarPrograma();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tu programa empezó de nuevo.')),
    );
  }

  Future<void> _alterarNotificacoes(bool ativado) async {
    if (ativado) {
      final anamnese = await widget.anamneseRepositorio.carregar();
      if (anamnese == null) {
        // Sem ficha ainda para agendar lembretes — só guarda a intenção.
        await widget.preferenciasRepositorio.definirNotificacoesAtivadas(true);
      } else {
        final ficha = widget.geradorFicha.gerar(anamnese);
        final diasDaSemana = await widget.preferenciasRepositorio.diasDaSemanaEscolhidos();
        final concedido = await widget.notificacoesService.ativar(
          ficha,
          diasDaSemana: diasDaSemana,
        );
        if (!concedido && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de notificaciones denegado.')),
          );
        }
      }
    } else {
      await widget.notificacoesService.desativar();
    }

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
              Text('Tus datos', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (anamnese == null)
                const Text('Completa la anamnesis en el onboarding para ver tus datos aquí.')
              else ...[
                _CardDadosAnamnese(anamnese: anamnese),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    key: const Key('botao-editar-anamnese'),
                    onPressed: () => _editarAnamnese(anamnese),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar mis datos'),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    key: const Key('botao-recomecar-programa'),
                    onPressed: _recomecarPrograma,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reiniciar mi programa'),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text('Notificaciones', style: Theme.of(context).textTheme.titleMedium),
              FutureBuilder<bool>(
                future: _notificacoesFuture,
                builder: (context, notifSnapshot) {
                  if (notifSnapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return SwitchListTile(
                    key: const Key('switch-notificacoes'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Recordatorios de entrenamiento y alimentación'),
                    value: notifSnapshot.data ?? true,
                    onChanged: _alterarNotificacoes,
                  );
                },
              ),
              const SizedBox(height: 24),
              Text('Cuenta', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.authRepositorio.usuarioAtual?.email ?? '—'),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        key: const Key('botao-sair'),
                        onPressed: () => widget.authRepositorio.sair(),
                        child: const Text('Cerrar sesión'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Suscripción', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'La cuenta y el inicio de sesión ya son reales. El cobro de la suscripción '
                    'todavía no está disponible en esta versión.',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Soporte', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Canal de soporte próximamente.'),
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
            _linha('Edad', '${anamnese.idade} años'),
            _linha('Altura', '${anamnese.alturaCm.toStringAsFixed(0)} cm'),
            _linha('Peso actual', '${anamnese.pesoAtualKg.toStringAsFixed(1)} kg'),
            if (anamnese.pesoDesejadoKg != null)
              _linha('Peso deseado', '${anamnese.pesoDesejadoKg!.toStringAsFixed(1)} kg'),
            _linha('Objetivo principal', anamnese.objetivoPrincipal.label),
            _linha('Nivel de actividad', anamnese.nivelAtividade.label),
            _linha('Frecuencia semanal', '${anamnese.frequenciaSemanalDias}x por semana'),
            if (anamnese.condicaoHormonal != 'Ninguna')
              _linha('Condición hormonal', anamnese.condicaoHormonal),
            if (anamnese.restricoesAlimentares.isNotEmpty)
              _linha('Restricciones alimentarias', anamnese.restricoesAlimentares.join(', ')),
            if (anamnese.lesoesLimitacoes.isNotEmpty)
              _linha('Lesiones/limitaciones', anamnese.lesoesLimitacoes.join(', ')),
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
          SizedBox(width: 170, child: Text(rotulo, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }
}
