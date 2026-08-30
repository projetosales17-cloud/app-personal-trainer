import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/anamnese.dart';
import 'onboarding/onboarding_flow.dart';
import '../services/anamnese_repository.dart';
import '../services/auth_repository.dart';
import '../services/foto_perfil_repository.dart';
import '../services/gerador_ficha_treino.dart';
import '../services/notificacoes_treino_service.dart';
import '../services/preferencias_repository.dart';
import '../services/programa_treino_repository.dart';
import '../widgets/avatar_perfil.dart';
import '../widgets/seletor_imagem.dart';

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
    FotoPerfilRepository? fotoPerfilRepositorio,
    SelecionarImagem? selecionarImagem,
  }) : anamneseRepositorio = anamneseRepositorio ?? AnamneseRepository(),
       preferenciasRepositorio = preferenciasRepositorio ?? PreferenciasRepository(),
       geradorFicha = geradorFicha ?? GeradorFichaTreino(),
       notificacoesService = notificacoesService ?? NotificacoesTreinoService(),
       authRepositorio = authRepositorio ?? AuthRepository(),
       programaRepositorio = programaRepositorio ?? ProgramaTreinoRepository(),
       fotoPerfilRepositorio = fotoPerfilRepositorio ?? FotoPerfilRepository(),
       selecionarImagem = selecionarImagem ?? selecionarImagemPadrao;

  final AnamneseRepository anamneseRepositorio;
  final PreferenciasRepository preferenciasRepositorio;
  final GeradorFichaTreino geradorFicha;
  final NotificacoesTreinoService notificacoesService;
  final AuthRepository authRepositorio;
  final ProgramaTreinoRepository programaRepositorio;
  final FotoPerfilRepository fotoPerfilRepositorio;
  final SelecionarImagem selecionarImagem;

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late Future<Anamnese?> _anamneseFuture = widget.anamneseRepositorio.carregar();
  late Future<bool> _notificacoesFuture = widget.preferenciasRepositorio.notificacoesAtivadas();
  bool _salvandoFoto = false;
  String? _fotoPerfil = FotoPerfilRepository.atual.value;

  @override
  void initState() {
    super.initState();
    FotoPerfilRepository.atual.addListener(_aoMudarFotoPerfil);
    // Preenche FotoPerfilRepository.atual (dispara _aoMudarFotoPerfil).
    widget.fotoPerfilRepositorio.carregar();
  }

  @override
  void dispose() {
    FotoPerfilRepository.atual.removeListener(_aoMudarFotoPerfil);
    super.dispose();
  }

  void _aoMudarFotoPerfil() {
    if (!mounted) return;
    setState(() => _fotoPerfil = FotoPerfilRepository.atual.value);
  }

  Future<void> _trocarFotoPerfil({required bool temFoto}) async {
    final acao = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              key: const Key('foto-perfil-camera'),
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.of(context).pop('camera'),
            ),
            ListTile(
              key: const Key('foto-perfil-galeria'),
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.of(context).pop('galeria'),
            ),
            if (temFoto)
              ListTile(
                key: const Key('foto-perfil-remover'),
                leading: const Icon(Icons.delete_outline),
                title: const Text('Quitar foto'),
                onTap: () => Navigator.of(context).pop('remover'),
              ),
          ],
        ),
      ),
    );
    if (acao == null || !mounted) return;

    if (acao == 'remover') {
      await widget.fotoPerfilRepositorio.remover();
      return;
    }

    final fonte = acao == 'camera' ? ImageSource.camera : ImageSource.gallery;
    final bytes = await widget.selecionarImagem(fonte);
    if (bytes == null || !mounted) return;
    if (bytes.lengthInBytes > FotoPerfilRepository.limiteBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto demasiado pesada. Prueba con otra o una de menor resolución.'),
        ),
      );
      return;
    }

    setState(() => _salvandoFoto = true);
    try {
      await widget.fotoPerfilRepositorio.salvar(bytes);
    } finally {
      if (mounted) setState(() => _salvandoFoto = false);
    }
  }

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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tu programa empezó de nuevo.')));
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Permiso de notificaciones denegado.')));
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
              _CabecalhoFotoPerfil(
                dataUri: _fotoPerfil,
                nome: (anamnese?.nome.isNotEmpty ?? false)
                    ? anamnese!.nome
                    : (anamnese?.nomeExibicao ?? ''),
                salvando: _salvandoFoto,
                aoTrocar: _trocarFotoPerfil,
              ),
              const SizedBox(height: 24),
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

/// Avatar grande no topo do Perfil com o botão de trocar/remover a foto.
class _CabecalhoFotoPerfil extends StatelessWidget {
  const _CabecalhoFotoPerfil({
    required this.dataUri,
    required this.nome,
    required this.salvando,
    required this.aoTrocar,
  });

  final String? dataUri;
  final String nome;
  final bool salvando;
  final Future<void> Function({required bool temFoto}) aoTrocar;

  @override
  Widget build(BuildContext context) {
    final temFoto = dataUri != null;
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              AvatarPerfil(dataUri: dataUri, nome: nome, raio: 48),
              if (salvando)
                const Positioned.fill(
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else
                Material(
                  color: Theme.of(context).colorScheme.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    key: const Key('botao-trocar-foto-perfil'),
                    customBorder: const CircleBorder(),
                    onTap: () => aoTrocar(temFoto: temFoto),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.photo_camera,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: salvando ? null : () => aoTrocar(temFoto: temFoto),
            child: Text(temFoto ? 'Cambiar foto' : 'Agregar foto'),
          ),
        ],
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
            if (anamnese.objetivosSecundarios.isNotEmpty)
              _linha(
                'Otros objetivos',
                anamnese.objetivosSecundarios.map((o) => o.label).join(', '),
              ),
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
          SizedBox(
            width: 170,
            child: Text(rotulo, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }
}
