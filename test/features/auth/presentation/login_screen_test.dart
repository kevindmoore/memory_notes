import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_notes/features/auth/application/auth_controller.dart';
import 'package:memory_notes/features/auth/presentation/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supa_manager/supa_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('LoginScreen', () {
    late _FakeSupaAuthManager fakeAuth;
    late AuthController controller;

    setUp(() {
      fakeAuth = _FakeSupaAuthManager();
      controller = AuthController(null, authManager: fakeAuth);
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: LoginScreen(
            auth: controller,
            onResult: (_) {},
          ),
        ),
      );
    }

    testWidgets('renders all sign-in elements by default', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Sign in to your Memory Notes'), findsOneWidget);
      expect(find.widgetWithText(TextField, ''), findsNWidgets(2)); // email & password
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Continue with Google'), findsOneWidget);
      expect(find.text('Create account'), findsOneWidget);
    });

    testWidgets('displays user-friendly error message when login fails with exception', (
      tester,
    ) async {
      fakeAuth.loginResult = const Result.failure(
        AuthException('Invalid login credentials', statusCode: '400'),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.enterText(find.byType(TextField).at(0), 'user@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'wrongpass');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      // Should display friendly formatted error, not raw AuthApiException
      expect(
        find.text('Problems logging in: Invalid email or password.'),
        findsOneWidget,
      );
      expect(find.textContaining('AuthApiException'), findsNothing);
    });

    testWidgets('tapping Forgot password with empty email shows prompt snackbar', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();

      expect(find.text('Enter your email to reset password'), findsOneWidget);
    });

    testWidgets('tapping Forgot password with invalid email format shows error snackbar', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.enterText(find.byType(TextField).at(0), 'invalidemail');
      await tester.pump();

      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('tapping Forgot password with valid email sends reset and shows success snackbar', (
      tester,
    ) async {
      fakeAuth.resetPasswordResult = const Result.success(true);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.pump();

      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();

      expect(fakeAuth.lastResetEmail, 'test@example.com');
      expect(find.text('Password reset email sent to test@example.com'), findsOneWidget);
    });

    testWidgets('tapping Forgot password shows error snackbar when reset fails', (
      tester,
    ) async {
      fakeAuth.resetPasswordResult = const Result.failure(
        AuthException('Email rate limit exceeded'),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.pump();

      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(SnackBar, 'Too many requests. Please wait a few minutes and try again.'),
        findsOneWidget,
      );
    });

    testWidgets('switching mode toggles between Sign In and Create Account', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('REPEAT PASSWORD'), findsNothing);

      final createAccountButton = find.widgetWithText(TextButton, 'Create account');
      await tester.ensureVisible(createAccountButton);
      await tester.pumpAndSettle();
      await tester.tap(createAccountButton);
      await tester.pumpAndSettle();

      expect(find.text('Create account'), findsOneWidget); // header
      expect(find.widgetWithText(ElevatedButton, 'Create Account'), findsOneWidget); // button
      expect(find.text('REPEAT PASSWORD'), findsOneWidget);

      final signInButton = find.widgetWithText(TextButton, 'Sign In');
      await tester.ensureVisible(signInButton);
      await tester.pumpAndSettle();
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
      expect(find.text('REPEAT PASSWORD'), findsNothing);
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
  Future<DatabaseUser?> loadUser() async => null;

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
