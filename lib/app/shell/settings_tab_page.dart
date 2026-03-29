import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:memory_notes/core/services/app_services.dart';
import 'package:memory_notes/features/settings/presentation/settings_screen.dart';

@RoutePage(name: 'SettingsTabRoute')
class SettingsTabPage extends StatelessWidget {
  const SettingsTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScreen(auth: AppServices.instance.auth);
  }
}
