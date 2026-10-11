import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:signals/signals.dart';
import 'package:supa_manager/supa_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum ConnectionStatus { unknown, online, offline, unavailable }

class ConnectionService {
  ConnectionService({Connectivity? connectivity, this.timeout = requestTimeout})
      : connectivity = connectivity ?? Connectivity();

  static const requestTimeout = Duration(seconds: 12);
  final Connectivity connectivity;
  final Duration timeout;
  final status = signal(ConnectionStatus.unknown);
  final isRetrying = signal(false);
  void Function()? onUnavailable;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _hasNetwork = true;
  int _failureRevision = 0;

  Future<void> initialize() async {
    _subscription ??= connectivity.onConnectivityChanged.listen(
      updateConnectivity,
      onError: (Object error) => reportFailure(error),
    );
    try {
      updateConnectivity(await connectivity.checkConnectivity().timeout(timeout));
    } catch (error) {
      reportFailure(error);
    }
  }

  void updateConnectivity(List<ConnectivityResult> results) {
    _hasNetwork = results.any((result) => result != ConnectivityResult.none);
    if (!_hasNetwork) {
      _failureRevision++;
      status.value = ConnectionStatus.offline;
      onUnavailable?.call();
    }
    // A network interface returning does not prove the backend is reachable.
  }

  Future<T> run<T>(Future<T> Function() operation) async {
    final revision = _failureRevision;
    try {
      final result = await operation().timeout(timeout);
      if (result is Failure) {
        reportFailure(result.error);
      } else if (result is ErrorMessage) {
        if (const [502, 503, 504].contains(result.code)) {
          reportFailure(PostgrestException(message: result.message ?? 'Unavailable', code: '${result.code}'));
        }
      } else if (result is Success && revision == _failureRevision) {
        _hasNetwork = true;
        status.value = ConnectionStatus.online;
      }
      return result;
    } catch (error) {
      reportFailure(error);
      rethrow;
    }
  }

  void reportFailure(Object error) {
    if (!isConnectionError(error)) return;
    _failureRevision++;
    status.value = _hasNetwork ? ConnectionStatus.unavailable : ConnectionStatus.offline;
    onUnavailable?.call();
  }

  static bool isConnectionError(Object error) {
    if (error is TimeoutException || error is AuthRetryableFetchException ||
        error is AuthTemporarilyUnavailableException ||
        error is DatabaseTemporarilyUnavailableException) return true;
    if (error is PostgrestException) {
      return const ['502', '503', '504'].contains(error.code);
    }
    final message = error.toString().toLowerCase();
    return message.contains('socketexception') ||
        message.contains('clientexception') ||
        message.contains('failed host lookup') ||
        message.contains('network is unreachable') ||
        message.contains('failed to fetch') ||
        message.contains('connection timeout') ||
        message.contains('timeoutexception') ||
        message.contains('connection refused') ||
        message.contains('connection reset') ||
        message.contains('temporarily unavailable');
  }

  static String loadErrorMessage(String error) => isConnectionError(StateError(error))
      ? 'Unable to load right now. Check your connection and try again.'
      : 'Unable to load right now. Please try again.';

  Future<void> retry(Future<void> Function() reload) async {
    if (isRetrying.value) return;
    isRetrying.value = true;
    try {
      await initialize();
      await reload();
    } catch (error) {
      reportFailure(error);
    } finally {
      isRetrying.value = false;
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
