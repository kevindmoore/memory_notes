import 'dart:async';

import 'package:memory_notes/core/services/connection_service.dart';

import 'package:lumberdash/lumberdash.dart';
import 'package:signals/signals_flutter.dart';
import 'package:supa_manager/supa_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const authRedirectUrl = 'https://mastertechsoftware.com/memory-notes/reset';

class AuthController {
  final Configuration? _config;
  final SupaAuthManager? _customAuth;
  StreamSubscription<AuthState>? _authSubscription;

  AuthController(this._config, {SupaAuthManager? authManager, this.connection}) : _customAuth = authManager {
    final authMgr = _authOrNull;
    if (authMgr != null) {
      try {
        _authSubscription = authMgr.client.auth.onAuthStateChange.listen(
          (state) {
            switch (state.event) {
              case AuthChangeEvent.signedIn:
              case AuthChangeEvent.tokenRefreshed:
              case AuthChangeEvent.userUpdated:
                isLoggedIn.value = state.session != null;
                break;
              case AuthChangeEvent.signedOut:
                isLoggedIn.value = false;
                break;
              case AuthChangeEvent.initialSession:
              case AuthChangeEvent.passwordRecovery:
              case AuthChangeEvent.mfaChallengeVerified:
                break;
              // ignore: deprecated_member_use
              case AuthChangeEvent.userDeleted:
                isLoggedIn.value = false;
                break;
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            if (_isMissingSessionError(error)) {
              isLoggedIn.value = false;
              return;
            }
            if (_isTemporaryAuthFetchError(error)) {
              connection?.reportFailure(error);
              logWarning(
                'Supabase auth is temporarily unavailable; keeping the current session state.',
              );
              return;
            }
            logError(error, stacktrace: stackTrace);
          },
        );
      } catch (_) {
        // Client might not be initialized in unit tests
      }
    }
  }

  final isLoggedIn = signal(false);
  final ConnectionService? connection;
  final isLoading = signal(false);
  final errorMessage = signal<String?>(null);

  SupaAuthManager get _auth => _customAuth ?? _config!.supaAuthManager;
  SupaAuthManager? get _authOrNull => _customAuth ?? _config?.supaAuthManager;

  Future<T> _request<T>(Future<T> Function() operation) => connection == null
      ? operation().timeout(ConnectionService.requestTimeout)
      : connection!.run(operation);

  String _authError(Object error, String fallback) {
    if (error is! AuthTemporarilyUnavailableException && ConnectionService.isConnectionError(error)) {
      return 'Unable to connect. Check your internet connection and try again.';
    }
    return parseAuthError(error, fallback: fallback);
  }

  Future<void> loadUser() async {
    isLoading.value = true;
    try {
      await _request(_auth.loadUser);
      isLoggedIn.value = _auth.isLoggedIn() || _auth.client.auth.currentSession != null;
    } catch (error, stackTrace) {
      if (_isMissingSessionError(error)) {
        isLoggedIn.value = false;
        return;
      }
      if (_isTemporaryAuthFetchError(error) || ConnectionService.isConnectionError(error)) {
        isLoggedIn.value = _auth.client.auth.currentSession != null || isLoggedIn.value;
        logWarning('Supabase auth is temporarily unavailable; keeping the current session state.');
        return;
      }
      logError(error, stacktrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  bool _isMissingSessionError(Object error) {
    return error is AuthException && error.code == 'session_missing';
  }

  bool _isTemporaryAuthFetchError(Object error) {
    return error is AuthRetryableFetchException;
  }

  Future<bool> loginWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final launched = await _request(() => _auth.loginWithOAuth(
        OAuthProvider.google,
        nativeRedirectUrl: authRedirectUrl,
      ));
      if (!launched) {
        errorMessage.value = 'Could not open Google sign-in.';
      }
      return launched;
    } catch (e, stackTrace) {
      errorMessage.value = _authError(e, 'Problems signing in with Google.');
      logError('AuthController.loginWithGoogle exception: $e', stacktrace: stackTrace);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final response = await _request(() => _auth.login(email, password));
      switch (response) {
        case Success():
          isLoggedIn.value = true;
          return true;
        case Failure(error: final error):
          logError('AuthController.login failure: $error');
          errorMessage.value = response.errorMessageFormatted(fallback: 'Problems logging in');
        case ErrorMessage(message: final message, code: _):
          logError('AuthController.login error: $message');
          errorMessage.value = response.errorMessageFormatted(fallback: 'Problems logging in');
      }
    } catch (e, stackTrace) {
      errorMessage.value = _authError(e, 'Problems logging in');
      logError('AuthController.login exception: $e', stacktrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  Future<bool> createUser(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final response = await _request(() => _auth.createUser(email, password));
      switch (response) {
        case Success(data: final data):
          if (data) {
            isLoggedIn.value = true;
          } else {
            errorMessage.value =
                'Could not create account. Please check your information and try again.';
          }
          return data;
        case Failure(error: final error):
          logError('AuthController.createUser failure: $error');
          errorMessage.value = response.errorMessageFormatted(fallback: 'Problems creating account');
        case ErrorMessage(message: final message, code: _):
          logError('AuthController.createUser error: $message');
          errorMessage.value = response.errorMessageFormatted(fallback: 'Problems creating account');
      }
    } catch (e, stackTrace) {
      errorMessage.value = _authError(e, 'Problems creating account');
      logError('AuthController.createUser exception: $e', stacktrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  Future<bool> resetPassword(String email) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      errorMessage.value = 'Please enter your email address to reset your password.';
      return false;
    }
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final response = await _request(() => _auth.resetPassword(trimmedEmail, authRedirectUrl));
      switch (response) {
        case Success():
          return true;
        case Failure(error: final error):
          logError('AuthController.resetPassword failure: $error');
          errorMessage.value = response.errorMessageFormatted(fallback: 'Problems resetting password');
          return false;
        case ErrorMessage(message: final message, code: _):
          logError('AuthController.resetPassword error: $message');
          errorMessage.value = response.errorMessageFormatted(fallback: 'Problems resetting password');
          return false;
      }
    } catch (e, stackTrace) {
      errorMessage.value = _authError(e, 'Problems resetting password');
      logError('AuthController.resetPassword exception: $e', stacktrace: stackTrace);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    try {
      _auth.logout();
    } catch (e) {
      logError('AuthController.logout: $e');
    }
    isLoggedIn.value = false;
  }

  String? get userName => _auth.getUser()?.name;

  String? get userId => _auth.getUserFromAuth()?.userId;

  String? get userEmail => _auth.getUserEmail() ?? _auth.client.auth.currentUser?.email;

  Future<void> dispose() async {
    await _authSubscription?.cancel();
  }
}
