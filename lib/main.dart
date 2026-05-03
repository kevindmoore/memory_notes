import 'package:colorize_lumberdash/colorize_lumberdash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumberdash/lumberdash.dart';
import 'package:signals/signals.dart';
import 'package:supa_manager/supa_manager.dart';
import 'package:utilities/utilities.dart';

import 'app/app.dart';
import 'core/services/app_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _installDebugKeyboardStateRecovery();

  SignalsObserver.instance = null;
  putLumberdashToWork(withClients: [ColorizeLumberdash()]);

  // Load Supabase credentials and initialize supa_manager (auth + db)
  final secrets = await SecretLoader(secretPath: 'assets/secrets.json').load();
  final config = Configuration();
  await config.initialize(secrets.url, secrets.apiKey, null);

  // Wire up all services using the initialized Configuration
  AppServices.initialize(config);
  final services = AppServices.instance;

  runApp(MemoryNotesApp(services: services));
}

void _installDebugKeyboardStateRecovery() {
  assert(() {
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (_isStaleKeyboardStateAssertion(details)) {
        (HardwareKeyboard.instance as dynamic).clearState();
        logWarning(
          'Recovered from a stale Flutter keyboard state assertion. '
          'This can happen on desktop after a missed key-up event.',
        );
        return;
      }
      previousOnError?.call(details);
    };
    return true;
  }());
}

bool _isStaleKeyboardStateAssertion(FlutterErrorDetails details) {
  final exception = details.exceptionAsString();
  return details.library == 'services library' &&
      exception.contains('HardwareKeyboard') &&
      exception.contains('physical key') &&
      (exception.contains('already pressed') || exception.contains('not pressed'));
}
