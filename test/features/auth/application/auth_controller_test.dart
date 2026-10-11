import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:memory_notes/features/auth/application/auth_controller.dart';
import 'package:memory_notes/core/services/connection_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supa_manager/supa_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('AuthController', () {
    late _FakeSupaAuthManager fakeAuth;
    late AuthController controller;

    setUp(() {
      fakeAuth = _FakeSupaAuthManager();
      controller = AuthController(null, authManager: fakeAuth);
    });

    test('stalled startup stops loading and preserves an existing login', () async {
      final client = SupabaseClient('https://example.com', 'test-key');
      fakeAuth.client = client;
      fakeAuth.loadUserFuture = Completer<DatabaseUser?>().future;
      final connection = ConnectionService(timeout: const Duration(milliseconds: 5));
      final offlineController = AuthController(null, authManager: fakeAuth, connection: connection);
      offlineController.isLoggedIn.value = true;
      await offlineController.loadUser();
      expect(offlineController.isLoading.value, isFalse);
      expect(offlineController.isLoggedIn.value, isTrue);
      expect(connection.status.value, ConnectionStatus.unavailable);
      await offlineController.dispose();
      await client.dispose();
    });

    test('login success updates isLoggedIn signal', () async {
      fakeAuth.loginResult = const Result.success(DatabaseUser(email: 'test@example.com'));

      final result = await controller.login('test@example.com', 'password123');

      expect(result, isTrue);
      expect(controller.isLoggedIn.value, isTrue);
      expect(controller.errorMessage.value, isNull);
    });

    test('login failure with invalid credentials formats friendly error message', () async {
      fakeAuth.loginResult = const Result.failure(
        AuthException('Invalid login credentials', statusCode: '400'),
      );

      final result = await controller.login('test@example.com', 'wrongpassword');

      expect(result, isFalse);
      expect(controller.isLoggedIn.value, isFalse);
      expect(controller.errorMessage.value, 'Problems logging in: Invalid email or password.');
    });

    test('login failure with temporary auth error formats friendly message', () async {
      fakeAuth.loginResult = Result.failure(
        AuthTemporarilyUnavailableException('Connection timeout'),
      );

      final result = await controller.login('test@example.com', 'password123');

      expect(result, isFalse);
      expect(
        controller.errorMessage.value,
        'Authentication service is temporarily unavailable. Please try again later.',
      );
    });

    test('createUser success updates isLoggedIn signal', () async {
      fakeAuth.createUserResult = const Result.success(true);

      final result = await controller.createUser('newuser@example.com', 'password123');

      expect(result, isTrue);
      expect(controller.isLoggedIn.value, isTrue);
      expect(controller.errorMessage.value, isNull);
    });

    test('createUser failure with existing user formats friendly error message', () async {
      fakeAuth.createUserResult = const Result.failure(
        AuthException('User already registered'),
      );

      final result = await controller.createUser('existing@example.com', 'password123');

      expect(result, isFalse);
      expect(controller.errorMessage.value, 'An account with this email already exists.');
    });

    test('resetPassword returns true and clears error on success', () async {
      fakeAuth.resetPasswordResult = const Result.success(true);

      final result = await controller.resetPassword('test@example.com');

      expect(result, isTrue);
      expect(controller.errorMessage.value, isNull);
      expect(fakeAuth.lastResetEmail, 'test@example.com');
    });

    test('resetPassword with empty email returns false and sets validation error', () async {
      final result = await controller.resetPassword('   ');

      expect(result, isFalse);
      expect(
        controller.errorMessage.value,
        'Please enter your email address to reset your password.',
      );
    });

    test('resetPassword failure sets formatted error message', () async {
      fakeAuth.resetPasswordResult = const Result.failure(
        AuthException('Email rate limit exceeded'),
      );

      final result = await controller.resetPassword('test@example.com');

      expect(result, isFalse);
      expect(
        controller.errorMessage.value,
        'Too many requests. Please wait a few minutes and try again.',
      );
    });

    test('logout clears loggedIn state', () {
      controller.isLoggedIn.value = true;
      controller.logout();
      expect(controller.isLoggedIn.value, isFalse);
      expect(fakeAuth.logoutCalled, isTrue);
    });

    test('login state notifies router listeners', () {
      var notificationCount = 0;
      void listener() => notificationCount++;
      controller.isLoggedIn.addListener(listener);

      controller.isLoggedIn.value = true;

      expect(notificationCount, 1);
      controller.isLoggedIn.removeListener(listener);
    });
  });
}

class _FakeSupaAuthManager implements SupaAuthManager {
  Result<DatabaseUser> loginResult = const Result.errorMessage(99, 'Problems logging in');
  Result<bool> createUserResult = const Result.errorMessage(99, 'Problems creating account');
  Result<bool> resetPasswordResult = const Result.success(true);
  bool loginWithOAuthResult = true;
  String? lastResetEmail;
  bool logoutCalled = false;
  Future<DatabaseUser?>? loadUserFuture;

  @override
  late SupabaseClient client;

  @override
  String getPersistSessionString(Session session) => '';

  @override
  String get apiKey => 'test-api-key';

  @override
  String? get emailRedirectUrl => null;

  @override
  LoginStateNotifier? get loginStateNotifier => null;

  @override
  SharedPreferences get prefs => throw UnimplementedError();

  @override
  Stream<bool> get onLoginStateChange => const Stream.empty();

  @override
  bool get isAuthTemporarilyUnavailable => false;

  @override
  Exception authenticationFailure() => SignedOutException();

  @override
  Future<Result<DatabaseUser>> login(String email, String password) async {
    return loginResult;
  }

  @override
  Future<Result<bool>> createUser(String email, String password) async {
    return createUserResult;
  }

  @override
  Future<Result<bool>> resetPassword(String email, [String? redirect]) async {
    lastResetEmail = email;
    return resetPasswordResult;
  }

  @override
  Future<bool> loginWithOAuth(
    OAuthProvider provider, {
    String? nativeRedirectUrl,
    String? webRedirectUrl,
    String? scopes,
    LaunchMode authScreenLaunchMode = LaunchMode.externalApplication,
    Map<String, String>? queryParams,
  }) async {
    return loginWithOAuthResult;
  }

  @override
  void logout() {
    logoutCalled = true;
  }

  @override
  Future<DatabaseUser?> loadUser() async => loadUserFuture == null ? null : await loadUserFuture;

  @override
  bool isLoggedIn() => false;

  @override
  DatabaseUser? getUser() => null;

  @override
  String? getUserEmail() => null;

  @override
  String? getUserPassword() => null;

  @override
  DatabaseUser? getUserFromAuth() => null;

  @override
  Future<Result<bool>> deleteCurrentUser() async => const Result.success(true);

  @override
  Future<bool> refreshSession() async => true;

  @override
  Future<User?> updateUserPassword(String email, String password) async => null;
}
