import 'package:flutter/material.dart';
import 'package:memory_notes/core/theme/app_theme.dart';
import 'package:memory_notes/features/auth/application/auth_controller.dart';

/// Handles app initialization before routing begins.
/// Shows a loading spinner while auth session is loading.
class StartupWrapper extends StatefulWidget {
  final Widget child;
  final AuthController auth;
  final Future<void> Function() preloadAllData;
  final Future<void> Function() initializeSync;

  const StartupWrapper({
    required this.child,
    required this.auth,
    required this.preloadAllData,
    required this.initializeSync,
    super.key,
  });

  @override
  State<StartupWrapper> createState() => _StartupWrapperState();
}

class _StartupWrapperState extends State<StartupWrapper> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    try {
      await widget.auth.loadUser();
      if (widget.auth.isLoggedIn.value) {
        await widget.preloadAllData();
        await widget.initializeSync();
      }
    } finally {
      if (mounted) {
        setState(() => _initialized = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.accent),
                SizedBox(height: 24),
                Text(
                  'Memory Notes',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return widget.child;
  }
}
