import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:memory_notes/core/services/app_services.dart';
import 'package:memory_notes/features/instant_notes/presentation/instant_notes_screen.dart';

@RoutePage(name: 'InstantNotesTabRoute')
class InstantNotesTabPage extends StatelessWidget {
  const InstantNotesTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppServices.instance;
    return InstantNotesScreen(
      instantNotes: services.instantNotes,
      todoFiles: services.todoFiles,
      categories: services.categories,
      speech: services.speech,
    );
  }
}
