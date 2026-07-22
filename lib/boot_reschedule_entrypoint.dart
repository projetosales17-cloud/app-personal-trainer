import 'package:flutter/widgets.dart';

import 'services/reagendamento_boot_service.dart';

/// Ponto de entrada headless (sem Activity/UI) chamado pelo BootReceiver
/// nativo Android depois que o aparelho reinicia. O `@pragma` é
/// obrigatório para o Flutter manter esse ponto de entrada acessível por
/// nome mesmo com tree-shaking em release — sem ele, `PluginUtilities`
/// não consegue resolver o handle do callback.
@pragma('vm:entry-point')
void reagendarNotificacoesAposBoot() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ReagendamentoBootService().executar();
}
