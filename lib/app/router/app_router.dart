import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:memory_notes/app/shell/main_shell.dart';
import 'package:memory_notes/app/shell/notes_tab_page.dart';
import 'package:memory_notes/app/shell/search_tab_page.dart';
import 'package:memory_notes/app/shell/settings_tab_page.dart';
import 'package:memory_notes/features/auth/application/auth_controller.dart';
import 'package:memory_notes/features/auth/presentation/login_screen.dart';
import 'package:memory_notes/features/notes/application/notes_mobile_store.dart';
import 'package:memory_notes/features/notes/application/notes_workspace_store.dart';
import 'package:memory_notes/features/notes/application/todo_controller.dart';
import 'package:memory_notes/features/notes/application/todo_file_controller.dart';
import 'package:memory_notes/features/notes/presentation/note_detail_screen.dart';
import 'package:memory_notes/features/notes/presentation/actions/notes_actions.dart';
import 'package:memory_notes/features/notes/presentation/note_edit_screen.dart';
import 'package:memory_notes/features/notes/presentation/notes_list_screen.dart';
import 'package:memory_notes/features/search/application/search_store.dart';
import 'package:memory_notes/features/search/presentation/search_screen.dart';
import 'package:memory_notes/features/settings/presentation/settings_screen.dart';
import 'package:memory_notes/features/speech/application/speech_controller.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  AppRouter({
    required this.auth,
  });

  final AuthController auth;

  @override
  List<AutoRoute> get routes => [
        AutoRoute(path: '/login', page: LoginRoute.page),
        AutoRoute(
          path: '/',
          page: MainShellRoute.page,
          children: [
            AutoRoute(path: 'notes', page: NotesTabRoute.page, initial: true),
            AutoRoute(path: 'search', page: SearchTabRoute.page),
            AutoRoute(path: 'settings', page: SettingsTabRoute.page),
          ],
        ),
        AutoRoute(path: '/notes/:fileId/detail', page: NoteDetailRoute.page),
        AutoRoute(path: '/notes/:fileId/:categoryId/edit', page: NoteEditRoute.page),
      ];

  @override
  late final List<AutoRouteGuard> guards = [
    AutoRouteGuard.simple((resolver, router) {
      final isLoggedIn = auth.isLoggedIn.value;
      if (isLoggedIn || resolver.routeName == LoginRoute.name) {
        resolver.next();
      } else {
        resolver.redirect(
          LoginRoute(
            auth: auth,
            onResult: (didLogin) {
              if (didLogin) resolver.next(true);
            },
          ),
        );
      }
    }),
  ];
}
