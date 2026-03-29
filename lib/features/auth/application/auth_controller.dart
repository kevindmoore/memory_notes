import 'package:lumberdash/lumberdash.dart';
import 'package:signals/signals.dart';
import 'package:supa_manager/supa_manager.dart';

class AuthController {
  final Configuration _config;

  AuthController(this._config);

  final isLoggedIn = signal(false);
  final isLoading = signal(false);
  final errorMessage = signal<String?>(null);

  SupaAuthManager get _auth => _config.supaAuthManager;

  Future<void> loadUser() async {
    isLoading.value = true;
    try {
      await _auth.loadUser();
      isLoggedIn.value = _auth.isLoggedIn();
    } catch (e) {
      logError('AuthController.loadUser: $e');
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
      _auth.resetPassword(
        email,
        'com.mastertechsoftware.memorynotes://login-callback',
      );
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

  String? get userEmail => _auth.getUserEmail();
}
