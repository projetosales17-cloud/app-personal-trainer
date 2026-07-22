package com.projetosales.app_personal_trainer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.view.FlutterCallbackInformation

/**
 * Reagenda os lembretes de treino depois que o aparelho reinicia — os
 * alarmes do flutter_local_notifications (AlarmManager) não sobrevivem a
 * um reboot. O handle do callback Dart a executar é salvo pelo próprio
 * app toda vez que inicia (ver lib/services/callback_boot_registro.dart);
 * esta receiver só lê esse handle e sobe um FlutterEngine headless (sem
 * Activity) para invocá-lo.
 *
 * Sem teste automatizado: depende de um reboot real de aparelho/emulador,
 * indisponível no ambiente de teste (mesma limitação de outras
 * integrações nativas deste projeto, como video_player).
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return

        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val handle = prefs.getLong("flutter.boot_reschedule_callback_handle", -1L)
        if (handle == -1L) return

        val callbackInfo = FlutterCallbackInformation.lookupCallbackInformation(handle) ?: return
        val appContext = context.applicationContext

        val loader = FlutterLoader()
        loader.startInitialization(appContext)
        loader.ensureInitializationCompleteAsync(appContext, null, Handler(context.mainLooper)) {
            val engine = FlutterEngine(appContext)
            GeneratedPluginRegistrant.registerWith(engine)
            engine.dartExecutor.executeDartCallback(
                DartExecutor.DartCallback(appContext.assets, loader.findAppBundlePath(), callbackInfo)
            )
        }
    }
}
