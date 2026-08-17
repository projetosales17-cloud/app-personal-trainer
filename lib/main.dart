import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/callback_boot_registro.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Reagendamento pós-boot é um mecanismo nativo Android (BootReceiver.kt) —
  // PluginUtilities.getCallbackHandle não tem implementação na web.
  if (!kIsWeb) {
    await registrarCallbackDeBoot();
  }
  runApp(App());
}
