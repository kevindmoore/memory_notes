import 'package:memory_notes/features/notes/application/category_controller.dart';
import 'package:memory_notes/features/notes/application/notes_query_service.dart';
import 'package:memory_notes/features/notes/application/notes_sync_service.dart';
import 'package:memory_notes/features/notes/application/notes_duplication_service.dart';
import 'package:supa_manager/supa_manager.dart';
import 'package:memory_notes/features/auth/application/auth_controller.dart';
import 'package:memory_notes/features/notes/application/notes_workspace_controller.dart';
import 'package:memory_notes/features/notes/application/notes_mobile_store.dart';
import 'package:memory_notes/features/notes/application/notes_workspace_store.dart';
import 'package:memory_notes/features/notes/application/todo_controller.dart';
import 'package:memory_notes/features/notes/application/todo_file_controller.dart';
import 'package:memory_notes/features/notes/data/repositories.dart';
import 'package:memory_notes/features/notes/presentation/actions/notes_actions.dart';
import 'package:memory_notes/features/search/application/search_store.dart';
import 'package:memory_notes/features/speech/application/speech_controller.dart';

/// Global service locator that wires auth, database, and feature controllers.
class AppServices {
  static late AppServices _instance;
  static AppServices get instance => _instance;

  late final AuthController auth;
  late final NotesWorkspaceController workspace;
  late final NotesQueryService notesQuery;
  late final NotesSyncService notesSync;
  late final NotesDuplicationService notesDuplication;
  late final NotesWorkspaceStore notesWorkspace;
  late final NotesMobileStore notesMobile;
  late final SearchStore search;
  late final SpeechController speech;
  late final NotesListActions notesListActions;
  late final NoteDetailActions noteDetailActions;
  late final NoteEditActions noteEditActions;
  late final CurrentStateRepository currentState;
  late final TodoFileController todoFiles;
  late final CategoryController categories;
  late final TodoController todos;

  AppServices._(Configuration config) {
    final db = config.supaDatabaseRepository;
    auth = AuthController(config);
    workspace = NotesWorkspaceController();
    notesQuery = const NotesQueryService();
    speech = SpeechController();
    currentState = CurrentStateRepository(db);
    todoFiles = TodoFileController(TodoFileRepository(db));
    categories = CategoryController(
      CategoryRepository(db),
      todoFiles: todoFiles,
    );
    todos = TodoController(
      TodoRepository(db),
      categories: categories,
      todoFiles: todoFiles,
    );
    notesDuplication = NotesDuplicationService(
      todoFiles: todoFiles,
      categories: categories,
      todos: todos,
      query: notesQuery,
    );
    notesWorkspace = NotesWorkspaceStore(
      workspace: workspace,
      currentState: currentState,
      query: notesQuery,
      todoFiles: todoFiles,
      categories: categories,
      todos: todos,
    );
    notesSync = NotesSyncService(
      database: db,
      query: notesQuery,
      workspace: workspace,
      notesWorkspace: notesWorkspace,
      todoFiles: todoFiles,
      categories: categories,
      todos: todos,
    );
    notesMobile = NotesMobileStore(
      todoFiles: todoFiles,
      categories: categories,
      todos: todos,
      query: notesQuery,
    );
    search = SearchStore(
      todoFiles: todoFiles,
      categories: categories,
      todos: todos,
      query: notesQuery,
    );
    notesListActions = NotesListActions(
      notesWorkspace: notesWorkspace,
      duplication: notesDuplication,
    );
    noteDetailActions = NoteDetailActions(
      todoFiles: todoFiles,
      notesMobile: notesMobile,
      duplication: notesDuplication,
    );
    noteEditActions = NoteEditActions(
      notesMobile: notesMobile,
      duplication: notesDuplication,
    );
  }

  static void initialize(Configuration config) {
    _instance = AppServices._(config);
  }

  /// Loads all files, then warms categories and todos for search/navigation.
  Future<void> preloadAllData() async {
    await todoFiles.load();
    final allFileIds = todoFiles.todoFiles.value
        .where((file) => file.id != null)
        .map((file) => file.id!)
        .toList();
    final savedFileIds = await currentState.getCurrentFileIds();
    final restoredFileIds = savedFileIds.where(allFileIds.contains).toList();
    workspace.setOpenFileIds(restoredFileIds);
    if (restoredFileIds.isNotEmpty) {
      workspace.selectFile(restoredFileIds.first);
    }
    await categories.loadAllForSearch(allFileIds);
    await Future.wait(
      categories.categories.value
          .where((category) => category.id != null)
          .map((category) => todos.loadTodos(category.id!)),
    );
  }
}
