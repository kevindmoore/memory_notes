import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:memory_notes/core/services/app_services.dart';
import 'package:memory_notes/features/search/presentation/search_screen.dart';

@RoutePage(name: 'SearchTabRoute')
class SearchTabPage extends StatelessWidget {
  const SearchTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppServices.instance;
    return SearchScreen(
      search: services.search,
      notesMobile: services.notesMobile,
      notesWorkspace: services.notesWorkspace,
      noteDetailActions: services.noteDetailActions,
      noteEditActions: services.noteEditActions,
      speech: services.speech,
    );
  }
}
