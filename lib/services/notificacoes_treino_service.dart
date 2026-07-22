import '../models/ficha_treino.dart';
import 'agendador_notificacoes.dart';
import 'preferencias_repository.dart';

/// Liga a preferência de notificações (Perfil) ao agendamento real de
/// lembretes de treino, a partir das datas sugeridas da ficha atual
/// (ver FichaTreino.datasPara).
class NotificacoesTreinoService {
  NotificacoesTreinoService({
    AgendadorNotificacoes? agendador,
    PreferenciasRepository? preferenciasRepositorio,
  }) : agendador = agendador ?? AgendadorNotificacoesLocal(),
       preferenciasRepositorio = preferenciasRepositorio ?? PreferenciasRepository();

  final AgendadorNotificacoes agendador;
  final PreferenciasRepository preferenciasRepositorio;

  /// Pede permissão e agenda os lembretes para todas as datas sugeridas da
  /// ficha. Retorna `false` (sem alterar a preferência salva) se a
  /// permissão for negada. [diasDaSemana], se informado, usa os dias da
  /// semana escolhidos manualmente pela usuária (ver
  /// `FichaTreino.datasPara`) em vez da distribuição automática.
  Future<bool> ativar(FichaTreino ficha, {List<int>? diasDaSemana}) async {
    final permitido = await agendador.solicitarPermissao();
    if (!permitido) return false;

    final datas = <DateTime>{};
    for (final dia in ficha.dias) {
      datas.addAll(ficha.datasPara(dia, diasDaSemana: diasDaSemana));
    }
    final ordenadas = datas.toList()..sort();

    await agendador.agendarLembretesDeTreino(ordenadas);
    await preferenciasRepositorio.definirNotificacoesAtivadas(true);
    return true;
  }

  Future<void> desativar() async {
    await agendador.cancelarTodos();
    await preferenciasRepositorio.definirNotificacoesAtivadas(false);
  }
}
