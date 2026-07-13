import 'dart:async';

import 'package:colorize_lumberdash/colorize_lumberdash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumberdash/lumberdash.dart';
import 'package:secrets_manager/secrets_manager.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:signals/signals.dart';
import 'package:supa_manager/supa_manager.dart';
import 'package:utilities/utilities.dart';

import 'app/app.dart';
import 'core/services/app_services.dart';
import 'firebase_options.dart';

const _sentryDsn = String.fromEnvironment('SENTRY_DSN');
const _sentryDiagnosticLogs = bool.fromEnvironment('SENTRY_DIAGNOSTIC_LOGS');
final _sentryEnabled = kReleaseMode && _sentryDsn.isNotEmpty;

Future<void> main() async {
  if (!_sentryEnabled) {
    await _runApp();
    return;
  }

  await SentryFlutter.init((options) {
    options.dsn = _sentryDsn;
    options.debug = _sentryDiagnosticLogs;
    options.diagnosticLevel = SentryLevel.debug;
    options.tracesSampleRate = 0;
    // options.profilesSampleRate = 0;
    options.enableNativeCrashHandling = true;
    options.anrEnabled = true;
    options.anrTimeoutInterval = const Duration(seconds: 5);
    options.enableWatchdogTerminationTracking = true;
    options.enableAutoPerformanceTracing = false;
    options.enableAutoSessionTracking = false;
    options.captureFailedRequests = false;
    options.enablePrintBreadcrumbs = false;
    options.enableAutoNativeBreadcrumbs = false;
    options.enableAppLifecycleBreadcrumbs = false;
    options.enableUserInteractionBreadcrumbs = false;
    options.enableUserInteractionTracing = false;
  }, appRunner: _runApp);
}

Future<void> _runApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  _installDebugKeyboardStateRecovery();

  SignalsObserver.instance = null;
  putLumberdashToWork(withClients: [ColorizeLumberdash(), if (_sentryEnabled) SentryLumberdash()]);
  _logSentryStartupState();
  await _initializeAppCheck();

  // Load Supabase credentials and initialize supa_manager (auth + db)
  final secrets = await SecretLoader(secretPath: 'assets/secrets.json').load();
  final config = Configuration();
  await config.initialize(secrets.url, secrets.apiKey, null);

  // Wire up all services using the initialized Configuration
  AppServices.initialize(config);
  final services = AppServices.instance;
  _installClosedSocketErrorRecovery(services.notesSync.handleRealtimeSocketClosed);

  runApp(MemoryNotesApp(services: services));
}

void _logSentryStartupState() {
  logMessage(
    'Sentry startup: release=$kReleaseMode, '
    'hasDsn=${_sentryDsn.isNotEmpty}, '
    'enabled=$_sentryEnabled, '
    'diagnostics=$_sentryDiagnosticLogs.',
  );
}

Future<void> _initializeAppCheck() async {
  try {
    logMessage('SecretsManager: initializing Firebase App Check.');
    await SecretsManager.initialize(options: DefaultFirebaseOptions.currentPlatform);
    logMessage('SecretsManager: Firebase App Check activated.');
    await _logAppCheckTokenStatus();
  } catch (error) {
    logError('SecretsManager: Firebase App Check initialization failed: $error');
  }
}

Future<void> _logAppCheckTokenStatus() async {
  try {
    final token = await SecretsManager.getAppCheckToken();
    if (token == null || token.isEmpty) {
      logWarning('SecretsManager: App Check token was empty.');
      return;
    }

    logMessage('SecretsManager: App Check token received (${token.length} characters).');
  } catch (error) {
    logError('SecretsManager: App Check token request failed: $error');
  }
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

void _installClosedSocketErrorRecovery(Future<void> Function() recoverRealtime) {
  final previousOnError = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stack) {
    if (_isClosedSocketReadError(error)) {
      logWarning('Recovering from a closed socket read from the realtime connection.');
      unawaited(recoverRealtime());
      return true;
    }
    return previousOnError?.call(error, stack) ?? false;
  };
}

bool _isClosedSocketReadError(Object error) {
  final message = error.toString();
  return message.contains('SocketException') && message.contains('Reading from a closed socket');
}

bool _isStaleKeyboardStateAssertion(FlutterErrorDetails details) {
  final exception = details.exceptionAsString();
  return details.library == 'services library' &&
      exception.contains('HardwareKeyboard') &&
      exception.contains('physical key') &&
      (exception.contains('already pressed') || exception.contains('not pressed'));
}

class SentryLumberdash extends LumberdashClient {
  static Future<SentryId> captureError(dynamic exception, [dynamic stacktrace]) {
    return Sentry.captureException(
      exception,
      stackTrace: stacktrace is StackTrace ? stacktrace : null,
    );
  }

  @override
  void logMessage(String message, [Map<String, String>? extras]) {}

  @override
  void logWarning(String message, [Map<String, String>? extras]) {}

  @override
  void logFatal(String message, [Map<String, String>? extras]) {
    unawaited(Sentry.captureMessage(message, level: SentryLevel.fatal));
  }

  @override
  void logError(dynamic exception, [dynamic stacktrace]) {
    unawaited(captureError(exception, stacktrace));
  }
}
