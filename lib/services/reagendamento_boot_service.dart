import 'anamnese_repository.dart';
import 'gerador_ficha_treino.dart';
import 'notificacoes_treino_service.dart';
import 'preferencias_repository.dart';

/// Reagenda os lembretes de treino depois que o aparelho reinicia —
/// alarmes do flutter_local_notifications (AlarmManager) não sobrevivem a
/// um reboot no Android. Chamado pelo ponto de entrada headless em
/// boot_reschedule_entrypoint.dart, que por sua vez é invocado pelo
/// BootReceiver nativo (ver android/.../BootReceiver.kt).
///
/// Separado em uma classe própria (em vez de ficar direto no ponto de
/// entrada `@pragma('vm:entry-point')`) para poder testar a lógica com
/// repositórios/serviço fakes, já que o ponto de entrada em si depende de
/// inicialização de binding indisponível no ambiente de teste.
class ReagendamentoBootService {
  ReagendamentoBootService({
    AnamneseRepository? anamneseRepositorio,
    PreferenciasRepository? preferenciasRepositorio,
    GeradorFichaTreino? geradorFicha,
    NotificacoesTreinoService? notificacoesService,
  }) : anamneseRepositorio = anamneseRepositorio ?? AnamneseRepository(),
       preferenciasRepositorio = preferenciasRepositorio ?? PreferenciasRepository(),
       geradorFicha = geradorFicha ?? GeradorFichaTreino(),
       notificacoesService = notificacoesService ?? NotificacoesTreinoService();

  final AnamneseRepository anamneseRepositorio;
  final PreferenciasRepository preferenciasRepositorio;
  final GeradorFichaTreino geradorFicha;
  final NotificacoesTreinoService notificacoesService;

  Future<void> executar() async {
    if (!await preferenciasRepositorio.notificacoesAtivadas()) return;

    final anamnese = await anamneseRepositorio.carregar();
    if (anamnese == null) return;

    final ficha = geradorFicha.gerar(anamnese);
    final diasDaSemana = await preferenciasRepositorio.diasDaSemanaEscolhidos();
    await notificacoesService.ativar(ficha, diasDaSemana: diasDaSemana);
  }
}
