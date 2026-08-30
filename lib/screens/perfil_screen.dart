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
  late Future<String?> _fotoPerfilFuture = widget.fotoPerfilRepositorio.carregar();
  bool _salvandoFoto = false;

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
              title: const Text('Tirar foto'),
              onTap: () => Navigator.of(context).pop('camera'),
            ),
            ListTile(
              key: const Key('foto-perfil-galeria'),
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.of(context).pop('galeria'),
            ),
            if (temFoto)
              ListTile(
                key: const Key('foto-perfil-remover'),
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remover foto'),
                onTap: () => Navigator.of(context).pop('remover'),
              ),
          ],
        ),
      ),
    );
    if (acao == null || !mounted) return;

    if (acao == 'remover') {
      await widget.fotoPerfilRepositorio.remover();
      if (!mounted) return;
      setState(() => _fotoPerfilFuture = widget.fotoPerfilRepositorio.carregar());
      return;
    }

    final fonte = acao == 'camera' ? ImageSource.camera : ImageSource.gallery;
    final bytes = await widget.selecionarImagem(fonte);
    if (bytes == null || !mounted) return;
    if (bytes.lengthInBytes > FotoPerfilRepository.limiteBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto muito pesada. Tente outra ou uma de menor resolução.'),
        ),
      );
      return;
    }

    setState(() => _salvandoFoto = true);
    try {
      await widget.fotoPerfilRepositorio.salvar(bytes);
    } finally {
      if (mounted) {
        setState(() {
          _salvandoFoto = false;
          _fotoPerfilFuture = widget.fotoPerfilRepositorio.carregar();
        });
      }
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
        title: const Text('Recomeçar seu programa?'),
        content: const Text(
          'Sua ficha volta a começar da fase de adaptação (semana 1). '
          'Sua anamnese e seu progresso registrado não são apagados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Recomeçar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await widget.programaRepositorio.recomecarPrograma();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seu programa começou de novo.')),
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
            const SnackBar(content: Text('Permissão de notificações negada.')),
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
              _CabecalhoFotoPerfil(
                fotoFuture: _fotoPerfilFuture,
                nome: (anamnese?.nome.isNotEmpty ?? false)
                    ? anamnese!.nome
                    : (anamnese?.nomeExibicao ?? ''),
                salvando: _salvandoFoto,
                aoTrocar: _trocarFotoPerfil,
              ),
              const SizedBox(height: 24),
              Text('Seus dados', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (anamnese == null)
                const Text('Complete a anamnese no onboarding para ver seus dados aqui.')
              else ...[
                _CardDadosAnamnese(anamnese: anamnese),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    key: const Key('botao-editar-anamnese'),
                    onPressed: () => _editarAnamnese(anamnese),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar meus dados'),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    key: const Key('botao-recomecar-programa'),
                    onPressed: _recomecarPrograma,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Recomeçar meu programa'),
                  ),
                ),
              ],
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
              Text('Conta', style: Theme.of(context).textTheme.titleMedium),
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
                        child: const Text('Sair da conta'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Assinatura', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'A conta e o login já são reais. A cobrança de assinatura ainda não '
                    'está disponível nesta versão.',
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

/// Avatar grande no topo do Perfil com o botão de trocar/remover a foto.
class _CabecalhoFotoPerfil extends StatelessWidget {
  const _CabecalhoFotoPerfil({
    required this.fotoFuture,
    required this.nome,
    required this.salvando,
    required this.aoTrocar,
  });

  final Future<String?> fotoFuture;
  final String nome;
  final bool salvando;
  final Future<void> Function({required bool temFoto}) aoTrocar;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: fotoFuture,
      builder: (context, snapshot) {
        final dataUri = snapshot.data;
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
                child: Text(temFoto ? 'Trocar foto' : 'Adicionar foto'),
              ),
            ],
          ),
        );
      },
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
            if (anamnese.objetivosSecundarios.isNotEmpty)
              _linha(
                'Outros objetivos',
                anamnese.objetivosSecundarios.map((o) => o.label).join(', '),
              ),
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
