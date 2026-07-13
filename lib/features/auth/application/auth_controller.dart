import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lumberdash/lumberdash.dart';
import 'package:signals/signals.dart';
import 'package:supa_manager/supa_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const authRedirectUrl = 'com.mastertechsoftware.memorynotes://login-callback';

class AuthController {
  final Configuration _config;
  StreamSubscription<AuthState>? _authSubscription;

  AuthController(this._config) {
    _authSubscription = _auth.client.auth.onAuthStateChange.listen(
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
        logError(error, stacktrace: stackTrace);
      },
    );
  }

  final isLoggedIn = signal(false);
  final isLoading = signal(false);
  final errorMessage = signal<String?>(null);

  SupaAuthManager get _auth => _config.supaAuthManager;

  Future<void> loadUser() async {
    isLoading.value = true;
    try {
      await _auth.loadUser();
      isLoggedIn.value = _auth.isLoggedIn() || _auth.client.auth.currentSession != null;
    } catch (error, stackTrace) {
      if (_isMissingSessionError(error)) {
        isLoggedIn.value = false;
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

  Future<bool> loginWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final launched = await _auth.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : authRedirectUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      if (!launched) {
        errorMessage.value = 'Could not open Google sign-in.';
      }
      return launched;
    } catch (e) {
      errorMessage.value = 'Google sign-in failed: $e';
      logError('AuthController.loginWithGoogle exception: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final response = await _auth.login(email, password);
      switch (response) {
        case Success():
          isLoggedIn.value = true;
          return true;
        case Failure(error: final error):
          logError('AuthController.login failure: $error');
          errorMessage.value = error.toString();
        case ErrorMessage(message: final message, code: _):
          logError('AuthController.login error: $message');
          errorMessage.value = message;
      }
    } catch (e) {
      errorMessage.value = 'Login failed: $e';
      logError('AuthController.login exception: $e');
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  Future<bool> createUser(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final response = await _auth.createUser(email, password);
      switch (response) {
        case Success(data: final data):
          if (data) {
            isLoggedIn.value = true;
          }
          return data;
        case Failure(error: final error):
          logError('AuthController.createUser failure: $error');
          errorMessage.value = error.toString();
        case ErrorMessage(message: final message, code: _):
          logError('AuthController.createUser error: $message');
          errorMessage.value = message;
      }
    } catch (e) {
      errorMessage.value = 'Account creation failed: $e';
      logError('AuthController.createUser exception: $e');
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  void resetPassword(String email) {
    try {
      _auth.resetPassword(email, authRedirectUrl);
    } catch (e) {
      logError('AuthController.resetPassword: $e');
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
