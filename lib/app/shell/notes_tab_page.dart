import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:memory_notes/core/services/app_services.dart';
import 'package:memory_notes/features/notes/presentation/notes_list_screen.dart';

@RoutePage(name: 'NotesTabRoute')
class NotesTabPage extends StatefulWidget {
  const NotesTabPage({super.key});

  @override
  State<NotesTabPage> createState() => _NotesTabPageState();
}

class _NotesTabPageState extends State<NotesTabPage> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  Future<bool> _handleBackButtonPressed() {
    if (context.tabsRouter.current.name != context.routeData.name) {
      return Future.value(false);
    }

    final navigator = _navigatorKey.currentState;
    if (navigator == null) return Future.value(false);
    return navigator.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final services = AppServices.instance;
    return BackButtonListener(
      onBackButtonPressed: _handleBackButtonPressed,
      child: Navigator(
        key: _navigatorKey,
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
      ),
    );
  }
}
