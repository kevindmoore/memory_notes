import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:memory_notes/app/router/app_router.dart';
import 'package:memory_notes/core/services/app_services.dart';
import 'package:memory_notes/core/theme/app_theme.dart';
import 'package:memory_notes/features/auth/application/auth_controller.dart';
import 'package:signals/signals_flutter.dart';

typedef OnLoginResult = void Function(bool didLogin);

@RoutePage(name: 'LoginRoute')
class LoginScreen extends StatefulWidget {
  final OnLoginResult? onResult;
  final AuthController? auth;

  const LoginScreen({this.onResult, this.auth, super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _repeatPasswordCtrl = TextEditingController();
  bool _isCreateMode = false;
  bool _hidePassword = true;
  bool _hideRepeatPassword = true;
  bool _navigatingAfterLogin = false;

  AuthController get _auth => widget.auth ?? AppServices.instance.auth;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _repeatPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = _auth;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SignalBuilder(
          builder: (context) {
            final isLoading = auth.isLoading.value;
            final error = auth.errorMessage.value;
            final isLoggedIn = auth.isLoggedIn.value;
            if (isLoggedIn && !_navigatingAfterLogin) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  unawaited(_completeLogin());
                }
              });
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  _buildPasswordField(_passwordCtrl, _hidePassword, (v) {
                    setState(() => _hidePassword = v);
                  }),
                  if (_isCreateMode) ...[
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      _repeatPasswordCtrl,
                      _hideRepeatPassword,
                      (v) => setState(() => _hideRepeatPassword = v),
                      hint: 'Repeat password',
                    ),
                  ],
                  if (!_isCreateMode) ...[const SizedBox(height: 12), _buildForgotPassword()],
                  if (error != null) ...[const SizedBox(height: 12), _buildError(error)],
                  const SizedBox(height: 28),
                  _buildPrimaryButton(isLoading, auth),
                  if (!_isCreateMode) ...[
                    const SizedBox(height: 12),
                    _buildGoogleButton(isLoading),
                  ],
                  const SizedBox(height: 20),
                  _buildSwitchModeRow(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App icon placeholder
        const SizedBox(height: 24),
        Text(
          _isCreateMode ? 'Create account' : 'Welcome back',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _isCreateMode ? 'Create your Memory Notes account' : 'Sign in to your Memory Notes',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EMAIL',
          style: TextStyle(
            color: AppColors.textDisabled,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'you@example.com',
            prefixIcon: Icon(Icons.email_outlined, color: AppColors.textDisabled, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    TextEditingController ctrl,
    bool hidden,
    void Function(bool) onToggle, {
    String hint = 'Min. 8 characters',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hint == 'Min. 8 characters' ? 'PASSWORD' : 'REPEAT PASSWORD',
          style: const TextStyle(
            color: AppColors.textDisabled,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          obscureText: hidden,
          textInputAction: TextInputAction.done,
          style: const TextStyle(color: AppColors.textPrimary),
          onSubmitted: (_) => _handlePrimary(widget.auth),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textDisabled, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppColors.textDisabled,
                size: 20,
              ),
              onPressed: () => onToggle(!hidden),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          if (_emailCtrl.text.isEmpty) {
            _showSnack('Enter your email to reset password');
            return;
          }
          _auth.resetPassword(_emailCtrl.text);
          _showSnack('Password reset email sent');
        },
        child: const Text('Forgot password?', style: TextStyle(color: AppColors.accentLight)),
      ),
    );
  }

  Widget _buildError(String error) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(error, style: const TextStyle(color: AppColors.error, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(bool isLoading, dynamic auth) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _handlePrimary(auth),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(_isCreateMode ? 'Create Account' : 'Sign In'),
      ),
    );
  }

  Widget _buildGoogleButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : () => unawaited(_auth.loginWithGoogle()),
        icon: const Icon(Icons.g_mobiledata, size: 24),
        label: const Text('Continue with Google'),
      ),
    );
  }

  Widget _buildSwitchModeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isCreateMode ? 'Already have an account?' : "Don't have an account?",
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _isCreateMode = !_isCreateMode;
              _auth.errorMessage.value = null;
            });
          },
          child: Text(
            _isCreateMode ? 'Sign In' : 'Create account',
            style: const TextStyle(color: AppColors.accentLight, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Future<void> _handlePrimary(dynamic auth) async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnack('Please fill in all fields');
      return;
    }

    bool success;
    if (_isCreateMode) {
      final repeat = _repeatPasswordCtrl.text;
      if (password != repeat) {
        _showSnack('Passwords do not match');
        return;
      }
      success = await _auth.createUser(email, password);
    } else {
      success = await _auth.login(email, password);
    }

    if (success) {
      await _completeLogin();
    }
  }

  Future<void> _completeLogin() async {
    if (!mounted || _navigatingAfterLogin) return;
    _navigatingAfterLogin = true;
    widget.onResult?.call(true);
    unawaited(AppServices.instance.preloadAllData());
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;

    final router = context.router;
    if (router.current.name == LoginRoute.name) {
      await router.replaceAll([const MainShellRoute()]);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 3)));
  }
}
