import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import '../boot_reschedule_entrypoint.dart';

/// Chave onde o handle do callback fica salvo — precisa bater com a
/// mesma chave lida por BootReceiver.kt (nativo Android). O
/// shared_preferences prefixa toda chave com "flutter." no arquivo de
/// preferências nativo; o lado Android já conta com esse prefixo.
const chaveHandleCallbackReboot = 'boot_reschedule_callback_handle';

/// Registra o handle do callback de reagendamento pós-boot. Idempotente:
/// o handle de uma mesma função `@pragma('vm:entry-point')` é estável
/// entre execuções do mesmo build do app, então é seguro (e necessário)
/// chamar isso toda vez que o app inicia — é a única forma do
/// BootReceiver nativo saber qual callback Dart invocar depois de um
/// reboot, já que ele roda sem nenhuma Activity/isolate Dart viva.
Future<void> registrarCallbackDeBoot() async {
  final handle = PluginUtilities.getCallbackHandle(reagendarNotificacoesAposBoot);
  if (handle == null) return;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(chaveHandleCallbackReboot, handle.toRawHandle());
}
