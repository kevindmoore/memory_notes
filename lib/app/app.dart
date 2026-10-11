import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memory_notes/core/presentation/connection_banner.dart';
import 'package:memory_notes/app/router/app_router.dart';
import 'package:memory_notes/core/services/app_services.dart';
import 'package:memory_notes/core/theme/app_theme.dart';
import 'package:memory_notes/features/auth/presentation/startup_wrapper.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class MemoryNotesApp extends StatefulWidget {
  const MemoryNotesApp({
    required this.services,
    super.key,
  });

  final AppServices services;

  @override
  State<MemoryNotesApp> createState() => _MemoryNotesAppState();
}

class _MemoryNotesAppState extends State<MemoryNotesApp> {
  late final _router = AppRouter(auth: widget.services.auth);

  @override
  void initState() {
    super.initState();
    unawaited(widget.services.connection.initialize());
  }

  @override
  void dispose() {
    unawaited(widget.services.connection.dispose());
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      routerConfig: _router.config(
        reevaluateListenable: widget.services.auth.isLoggedIn,
      ),
      title: 'Memory Notes',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      builder: (context, child) {
        return Column(
          children: [
            ConnectionBanner(
              connection: widget.services.connection,
              onRetry: widget.services.retryConnection,
            ),
            Expanded(
              child: StartupWrapper(
                auth: widget.services.auth,
                preloadAllData: widget.services.preloadAllData,
                initializeSync: widget.services.notesSync.initialize,
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ],
        );
      },
    );
  }
}
