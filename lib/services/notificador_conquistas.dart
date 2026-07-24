import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Abstração para disparar uma notificação local imediata (ex: marco de
/// gamificação batido) — permite substituir por um fake nos testes, já
/// que a implementação real depende de canais de plataforma
/// indisponíveis no ambiente de teste. Separado de `AgendadorNotificacoes`
/// (que agenda lembretes futuros) por ser um disparo imediato, não um
/// agendamento.
abstract class NotificadorConquistas {
  Future<void> notificar({required String titulo, required String corpo});
}

class NotificadorConquistasLocal implements NotificadorConquistas {
  NotificadorConquistasLocal({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _inicializado = false;

  static const _idCanal = 'conquistas_gamificacao';
  static const _idNotificacao = 777001;

  Future<void> _garantirInicializado() async {
    if (_inicializado) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _inicializado = true;
  }

  @override
  Future<void> notificar({required String titulo, required String corpo}) async {
    await _garantirInicializado();
    await _plugin.show(
      id: _idNotificacao,
      title: titulo,
      body: corpo,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(_idCanal, 'Conquistas'),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
