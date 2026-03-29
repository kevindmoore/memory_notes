import 'package:colorize_lumberdash/colorize_lumberdash.dart';
import 'package:flutter/material.dart';
import 'package:lumberdash/lumberdash.dart';
import 'package:signals/signals.dart';
import 'package:supa_manager/supa_manager.dart';
import 'package:utilities/utilities.dart';

import 'app/app.dart';
import 'core/services/app_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
