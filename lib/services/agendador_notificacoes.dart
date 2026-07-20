import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Abstração para agendar notificações locais — permite substituir por um
/// fake nos testes, já que a implementação real depende de canais de
/// plataforma indisponíveis no ambiente de teste.
abstract class AgendadorNotificacoes {
  Future<bool> solicitarPermissao();
  Future<void> agendarLembretesDeTreino(List<DateTime> datas);
  Future<void> cancelarTodos();
}

/// Implementação real usando flutter_local_notifications. Lembrete fixo às
/// 8h no dia de cada treino sugerido (ver FichaTreino.datasPara) — sem
/// escolha de horário pela usuária ainda (ver briefing do produto).
class AgendadorNotificacoesLocal implements AgendadorNotificacoes {
  AgendadorNotificacoesLocal({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _inicializado = false;

  static const _horaLembrete = 8;
  static const _idCanal = 'lembretes_treino';

  Future<void> _garantirInicializado() async {
    if (_inicializado) return;
    tz_data.initializeTimeZones();
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
  Future<bool> solicitarPermissao() async {
    await _garantirInicializado();

    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final concedidoAndroid = await android?.requestNotificationsPermission();

    final ios = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final concedidoIOS = await ios?.requestPermissions(alert: true, badge: true, sound: true);

    return (concedidoAndroid ?? true) && (concedidoIOS ?? true);
  }

  @override
  Future<void> agendarLembretesDeTreino(List<DateTime> datas) async {
    await _garantirInicializado();
    await cancelarTodos();

    final agora = tz.TZDateTime.now(tz.local);
    var proximoId = 0;
    for (final data in datas) {
      final agendadoPara = tz.TZDateTime.local(data.year, data.month, data.day, _horaLembrete);
      if (agendadoPara.isBefore(agora)) continue;

      await _plugin.zonedSchedule(
        id: proximoId,
        title: 'Treino de hoje',
        body: 'Confira sua ficha de treino no app.',
        scheduledDate: agendadoPara,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(_idCanal, 'Lembretes de treino'),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      proximoId++;
    }
  }

  @override
  Future<void> cancelarTodos() => _plugin.cancelAll();
}
