// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [InstantNotesTabPage]
class InstantNotesTabRoute extends PageRouteInfo<void> {
  const InstantNotesTabRoute({List<PageRouteInfo>? children})
    : super(InstantNotesTabRoute.name, initialChildren: children);

  static const String name = 'InstantNotesTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const InstantNotesTabPage();
    },
  );
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    OnLoginResult? onResult,
    AuthController? auth,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         LoginRoute.name,
         args: LoginRouteArgs(onResult: onResult, auth: auth, key: key),
         initialChildren: children,
       );

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () => const LoginRouteArgs(),
      );
      return LoginScreen(
        onResult: args.onResult,
        auth: args.auth,
        key: args.key,
      );
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.onResult, this.auth, this.key});

  final OnLoginResult? onResult;

  final AuthController? auth;

  final Key? key;

  @override
  String toString() {
    return 'LoginRouteArgs{onResult: $onResult, auth: $auth, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LoginRouteArgs) return false;
    return onResult == other.onResult && auth == other.auth && key == other.key;
  }

  @override
  int get hashCode => onResult.hashCode ^ auth.hashCode ^ key.hashCode;
}

/// generated route for
/// [MainShell]
class MainShellRoute extends PageRouteInfo<void> {
  const MainShellRoute({List<PageRouteInfo>? children})
    : super(MainShellRoute.name, initialChildren: children);

  static const String name = 'MainShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainShell();
    },
  );
}

/// generated route for
/// [NoteDetailScreen]
class NoteDetailRoute extends PageRouteInfo<NoteDetailRouteArgs> {
  NoteDetailRoute({
    required int fileId,
    required NotesMobileStore notesMobile,
    required NoteDetailActions noteDetailActions,
    required NoteEditActions noteEditActions,
    required SpeechController speech,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         NoteDetailRoute.name,
         args: NoteDetailRouteArgs(
           fileId: fileId,
           notesMobile: notesMobile,
           noteDetailActions: noteDetailActions,
           noteEditActions: noteEditActions,
           speech: speech,
           key: key,
         ),
         rawPathParams: {'fileId': fileId},
         initialChildren: children,
       );

  static const String name = 'NoteDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NoteDetailRouteArgs>();
      return NoteDetailScreen(
        fileId: args.fileId,
        notesMobile: args.notesMobile,
        noteDetailActions: args.noteDetailActions,
        noteEditActions: args.noteEditActions,
        speech: args.speech,
        key: args.key,
      );
    },
  );
}

class NoteDetailRouteArgs {
  const NoteDetailRouteArgs({
    required this.fileId,
    required this.notesMobile,
    required this.noteDetailActions,
    required this.noteEditActions,
    required this.speech,
    this.key,
  });

  final int fileId;

  final NotesMobileStore notesMobile;

  final NoteDetailActions noteDetailActions;

  final NoteEditActions noteEditActions;

  final SpeechController speech;

  final Key? key;

  @override
  String toString() {
    return 'NoteDetailRouteArgs{fileId: $fileId, notesMobile: $notesMobile, noteDetailActions: $noteDetailActions, noteEditActions: $noteEditActions, speech: $speech, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NoteDetailRouteArgs) return false;
    return fileId == other.fileId &&
        notesMobile == other.notesMobile &&
        noteDetailActions == other.noteDetailActions &&
        noteEditActions == other.noteEditActions &&
        speech == other.speech &&
        key == other.key;
  }

  @override
  int get hashCode =>
      fileId.hashCode ^
      notesMobile.hashCode ^
      noteDetailActions.hashCode ^
      noteEditActions.hashCode ^
      speech.hashCode ^
      key.hashCode;
}

/// generated route for
/// [NoteEditScreen]
class NoteEditRoute extends PageRouteInfo<NoteEditRouteArgs> {
  NoteEditRoute({
    required int fileId,
    required int categoryId,
    int? parentTodoId,
    int? focusedTodoId,
    bool openFocusedTodoNotes = false,
    required NotesMobileStore notesMobile,
    required NoteEditActions noteEditActions,
    required SpeechController speech,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         NoteEditRoute.name,
         args: NoteEditRouteArgs(
           fileId: fileId,
           categoryId: categoryId,
           parentTodoId: parentTodoId,
           focusedTodoId: focusedTodoId,
           openFocusedTodoNotes: openFocusedTodoNotes,
           notesMobile: notesMobile,
           noteEditActions: noteEditActions,
           speech: speech,
           key: key,
         ),
         rawPathParams: {'fileId': fileId, 'categoryId': categoryId},
         initialChildren: children,
       );

  static const String name = 'NoteEditRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NoteEditRouteArgs>();
      return NoteEditScreen(
        fileId: args.fileId,
        categoryId: args.categoryId,
        parentTodoId: args.parentTodoId,
        focusedTodoId: args.focusedTodoId,
        openFocusedTodoNotes: args.openFocusedTodoNotes,
        notesMobile: args.notesMobile,
        noteEditActions: args.noteEditActions,
        speech: args.speech,
        key: args.key,
      );
    },
  );
}

class NoteEditRouteArgs {
  const NoteEditRouteArgs({
    required this.fileId,
    required this.categoryId,
    this.parentTodoId,
    this.focusedTodoId,
    this.openFocusedTodoNotes = false,
    required this.notesMobile,
    required this.noteEditActions,
    required this.speech,
    this.key,
  });

  final int fileId;

  final int categoryId;

  final int? parentTodoId;

  final int? focusedTodoId;

  final bool openFocusedTodoNotes;

  final NotesMobileStore notesMobile;

  final NoteEditActions noteEditActions;

  final SpeechController speech;

  final Key? key;

  @override
  String toString() {
    return 'NoteEditRouteArgs{fileId: $fileId, categoryId: $categoryId, parentTodoId: $parentTodoId, focusedTodoId: $focusedTodoId, openFocusedTodoNotes: $openFocusedTodoNotes, notesMobile: $notesMobile, noteEditActions: $noteEditActions, speech: $speech, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NoteEditRouteArgs) return false;
    return fileId == other.fileId &&
        categoryId == other.categoryId &&
        parentTodoId == other.parentTodoId &&
        focusedTodoId == other.focusedTodoId &&
        openFocusedTodoNotes == other.openFocusedTodoNotes &&
        notesMobile == other.notesMobile &&
        noteEditActions == other.noteEditActions &&
        speech == other.speech &&
        key == other.key;
  }

  @override
  int get hashCode =>
      fileId.hashCode ^
      categoryId.hashCode ^
      parentTodoId.hashCode ^
      focusedTodoId.hashCode ^
      openFocusedTodoNotes.hashCode ^
      notesMobile.hashCode ^
      noteEditActions.hashCode ^
      speech.hashCode ^
      key.hashCode;
}

/// generated route for
/// [NotesListScreen]
class NotesListRoute extends PageRouteInfo<NotesListRouteArgs> {
  NotesListRoute({
    required NotesWorkspaceStore notesWorkspace,
    required TodoFileController todoFiles,
    required TodoController todos,
    required NotesListActions notesListActions,
    required NoteDetailActions noteDetailActions,
    required NotesMobileStore notesMobile,
    required NoteEditActions noteEditActions,
    required SpeechController speech,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         NotesListRoute.name,
         args: NotesListRouteArgs(
           notesWorkspace: notesWorkspace,
           todoFiles: todoFiles,
           todos: todos,
           notesListActions: notesListActions,
           noteDetailActions: noteDetailActions,
           notesMobile: notesMobile,
           noteEditActions: noteEditActions,
           speech: speech,
           key: key,
         ),
         initialChildren: children,
       );

  static const String name = 'NotesListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NotesListRouteArgs>();
      return NotesListScreen(
        notesWorkspace: args.notesWorkspace,
        todoFiles: args.todoFiles,
        todos: args.todos,
        notesListActions: args.notesListActions,
        noteDetailActions: args.noteDetailActions,
        notesMobile: args.notesMobile,
        noteEditActions: args.noteEditActions,
        speech: args.speech,
        key: args.key,
      );
    },
  );
}

class NotesListRouteArgs {
  const NotesListRouteArgs({
    required this.notesWorkspace,
    required this.todoFiles,
    required this.todos,
    required this.notesListActions,
    required this.noteDetailActions,
    required this.notesMobile,
    required this.noteEditActions,
    required this.speech,
    this.key,
  });

  final NotesWorkspaceStore notesWorkspace;

  final TodoFileController todoFiles;

  final TodoController todos;

  final NotesListActions notesListActions;

  final NoteDetailActions noteDetailActions;

  final NotesMobileStore notesMobile;

  final NoteEditActions noteEditActions;

  final SpeechController speech;

  final Key? key;

  @override
  String toString() {
    return 'NotesListRouteArgs{notesWorkspace: $notesWorkspace, todoFiles: $todoFiles, todos: $todos, notesListActions: $notesListActions, noteDetailActions: $noteDetailActions, notesMobile: $notesMobile, noteEditActions: $noteEditActions, speech: $speech, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NotesListRouteArgs) return false;
    return notesWorkspace == other.notesWorkspace &&
        todoFiles == other.todoFiles &&
        todos == other.todos &&
        notesListActions == other.notesListActions &&
        noteDetailActions == other.noteDetailActions &&
        notesMobile == other.notesMobile &&
        noteEditActions == other.noteEditActions &&
        speech == other.speech &&
        key == other.key;
  }

  @override
  int get hashCode =>
      notesWorkspace.hashCode ^
      todoFiles.hashCode ^
      todos.hashCode ^
      notesListActions.hashCode ^
      noteDetailActions.hashCode ^
      notesMobile.hashCode ^
      noteEditActions.hashCode ^
      speech.hashCode ^
      key.hashCode;
}

/// generated route for
/// [NotesTabPage]
class NotesTabRoute extends PageRouteInfo<void> {
  const NotesTabRoute({List<PageRouteInfo>? children})
    : super(NotesTabRoute.name, initialChildren: children);

  static const String name = 'NotesTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NotesTabPage();
    },
  );
}

/// generated route for
/// [SearchScreen]
class SearchRoute extends PageRouteInfo<SearchRouteArgs> {
  SearchRoute({
    required SearchStore search,
    required NotesMobileStore notesMobile,
    required NotesWorkspaceStore notesWorkspace,
    required NoteDetailActions noteDetailActions,
    required NoteEditActions noteEditActions,
    required SpeechController speech,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         SearchRoute.name,
         args: SearchRouteArgs(
           search: search,
           notesMobile: notesMobile,
           notesWorkspace: notesWorkspace,
           noteDetailActions: noteDetailActions,
           noteEditActions: noteEditActions,
           speech: speech,
           key: key,
         ),
         initialChildren: children,
       );

  static const String name = 'SearchRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SearchRouteArgs>();
      return SearchScreen(
        search: args.search,
        notesMobile: args.notesMobile,
        notesWorkspace: args.notesWorkspace,
        noteDetailActions: args.noteDetailActions,
        noteEditActions: args.noteEditActions,
        speech: args.speech,
        key: args.key,
      );
    },
  );
}

class SearchRouteArgs {
  const SearchRouteArgs({
    required this.search,
    required this.notesMobile,
    required this.notesWorkspace,
    required this.noteDetailActions,
    required this.noteEditActions,
    required this.speech,
    this.key,
  });

  final SearchStore search;

  final NotesMobileStore notesMobile;

  final NotesWorkspaceStore notesWorkspace;

  final NoteDetailActions noteDetailActions;

  final NoteEditActions noteEditActions;

  final SpeechController speech;

  final Key? key;

  @override
  String toString() {
    return 'SearchRouteArgs{search: $search, notesMobile: $notesMobile, notesWorkspace: $notesWorkspace, noteDetailActions: $noteDetailActions, noteEditActions: $noteEditActions, speech: $speech, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SearchRouteArgs) return false;
    return search == other.search &&
        notesMobile == other.notesMobile &&
        notesWorkspace == other.notesWorkspace &&
        noteDetailActions == other.noteDetailActions &&
        noteEditActions == other.noteEditActions &&
        speech == other.speech &&
        key == other.key;
  }

  @override
  int get hashCode =>
      search.hashCode ^
      notesMobile.hashCode ^
      notesWorkspace.hashCode ^
      noteDetailActions.hashCode ^
      noteEditActions.hashCode ^
      speech.hashCode ^
      key.hashCode;
}

/// generated route for
/// [SearchTabPage]
class SearchTabRoute extends PageRouteInfo<void> {
  const SearchTabRoute({List<PageRouteInfo>? children})
    : super(SearchTabRoute.name, initialChildren: children);

  static const String name = 'SearchTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SearchTabPage();
    },
  );
}

/// generated route for
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<SettingsRouteArgs> {
  SettingsRoute({
    required AuthController auth,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         SettingsRoute.name,
         args: SettingsRouteArgs(auth: auth, key: key),
         initialChildren: children,
       );

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SettingsRouteArgs>();
      return SettingsScreen(auth: args.auth, key: args.key);
    },
  );
}

class SettingsRouteArgs {
  const SettingsRouteArgs({required this.auth, this.key});

  final AuthController auth;

  final Key? key;

  @override
  String toString() {
    return 'SettingsRouteArgs{auth: $auth, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SettingsRouteArgs) return false;
    return auth == other.auth && key == other.key;
  }

  @override
  int get hashCode => auth.hashCode ^ key.hashCode;
}

/// generated route for
/// [SettingsTabPage]
class SettingsTabRoute extends PageRouteInfo<void> {
  const SettingsTabRoute({List<PageRouteInfo>? children})
    : super(SettingsTabRoute.name, initialChildren: children);

  static const String name = 'SettingsTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsTabPage();
    },
  );
}
