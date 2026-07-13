import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:memory_notes/core/services/app_services.dart';
import 'package:memory_notes/features/notes/presentation/notes_list_screen.dart';

@RoutePage(name: 'NotesTabRoute')
class NotesTabPage extends StatelessWidget {
  const NotesTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppServices.instance;
    return Navigator(
      onGenerateRoute: (settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => NotesListScreen(
          notesWorkspace: services.notesWorkspace,
          todoFiles: services.todoFiles,
          todos: services.todos,
          notesListActions: services.notesListActions,
          noteDetailActions: services.noteDetailActions,
          notesMobile: services.notesMobile,
          noteEditActions: services.noteEditActions,
          speech: services.speech,
        ),
      ),
    );
  }
}
