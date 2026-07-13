import 'package:memory_notes/features/notes/application/category_controller.dart';
import 'package:memory_notes/features/instant_notes/application/instant_notes_store.dart';
import 'package:memory_notes/features/notes/application/notes_query_service.dart';
import 'package:memory_notes/features/notes/application/notes_merge_service.dart';
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
import 'package:secrets_manager/secrets_manager.dart';

/// Global service locator that wires auth, database, and feature controllers.
class AppServices {
  static late AppServices _instance;
  static AppServices get instance => _instance;

  late final AuthController auth;
  late final NotesWorkspaceController workspace;
  late final NotesQueryService notesQuery;
  late final NotesSyncService notesSync;
  late final NotesDuplicationService notesDuplication;
  late final NotesMergeService notesMerge;
  late final NotesWorkspaceStore notesWorkspace;
  late final NotesMobileStore notesMobile;
  late final InstantNotesStore instantNotes;
  late final SearchStore search;
  late final SpeechController speech;
  late final NotesListActions notesListActions;
  late final NoteDetailActions noteDetailActions;
  late final NoteEditActions noteEditActions;
  late final DeviceWorkspaceStateRepository deviceWorkspaceState;
  late final TodoFileController todoFiles;
  late final CategoryController categories;
  late final TodoController todos;
  late final SecretsManager secrets;

  AppServices._(Configuration config) {
    final db = config.supaDatabaseRepository;
    secrets = SecretsManager.supabase();
    auth = AuthController(config);
    workspace = NotesWorkspaceController();
    notesQuery = const NotesQueryService();
    speech = SpeechController();
    deviceWorkspaceState = DeviceWorkspaceStateRepository(
      currentUserId: () => auth.userId,
    );
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
    instantNotes = InstantNotesStore(InstantNoteRepository(db), todos);
    notesDuplication = NotesDuplicationService(
      todoFiles: todoFiles,
      categories: categories,
      todos: todos,
      query: notesQuery,
    );
    notesMerge = NotesMergeService(
      todoFiles: todoFiles,
      categories: categories,
      todos: todos,
      query: notesQuery,
    );
    notesWorkspace = NotesWorkspaceStore(
      workspace: workspace,
      deviceWorkspaceState: deviceWorkspaceState,
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
      merge: notesMerge,
    );
    noteDetailActions = NoteDetailActions(
      todoFiles: todoFiles,
      notesMobile: notesMobile,
      notesWorkspace: notesWorkspace,
      duplication: notesDuplication,
      merge: notesMerge,
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
    await categories.loadAllForSearch(allFileIds);
    for (final category in categories.categories.value.where((category) => category.id != null)) {
      final loaded = await todos.loadTodos(category.id!);
      if (!loaded) {
        break;
      }
    }
  }
}
