import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_notes/core/services/connection_service.dart';
import 'package:memory_notes/features/notes/application/category_controller.dart';
import 'package:memory_notes/features/notes/application/notes_query_service.dart';
import 'package:memory_notes/features/notes/application/notes_sync_service.dart';
import 'package:memory_notes/features/notes/application/notes_workspace_controller.dart';
import 'package:memory_notes/features/notes/application/notes_workspace_store.dart';
import 'package:memory_notes/features/notes/application/todo_controller.dart';
import 'package:memory_notes/features/notes/application/todo_file_controller.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/data/repositories.dart';
import 'package:supa_manager/supa_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('reconnection refreshes notes and instant notes; manual retry bypasses cooldown', () async {
    final connectivity = _Connectivity();
    final connection = ConnectionService(connectivity: connectivity);
    final databaseEvents = StreamController<PostgresChangePayload>.broadcast();
    final database = _Database(databaseEvents);
    final files = TodoFileController(TodoFileRepository(database, connection: connection));
    final categories = CategoryController(CategoryRepository(database, connection: connection));
    final todos = TodoController(TodoRepository(database, connection: connection));
    final workspace = NotesWorkspaceController();
    final store = NotesWorkspaceStore(
      workspace: workspace,
      deviceWorkspaceState: _DeviceState(),
      query: const NotesQueryService(),
      todoFiles: files,
      categories: categories,
      todos: todos,
    );
    final recovered = Completer<void>();
    var instantReloads = 0;
    final sync = NotesSyncService(
      database: database,
      query: const NotesQueryService(),
      workspace: workspace,
      notesWorkspace: store,
      todoFiles: files,
      categories: categories,
      todos: todos,
      connectivity: connectivity,
      connection: connection,
      recoveryReloadCooldown: const Duration(hours: 1),
      reloadInstantNotes: () async { instantReloads++; },
      onRecovered: () { if (!recovered.isCompleted) recovered.complete(); },
    );
    connection.onUnavailable = sync.scheduleRecoveryRetry;
    await connection.initialize();
    await sync.initialize();
    await todos.loadTodos(10);

    connectivity.emit(ConnectivityResult.none);
    await Future<void>.delayed(Duration.zero);
    database.failNextTodoRead = true;
    expect(await todos.loadTodos(10), isFalse);
    expect(connection.status.value, ConnectionStatus.offline);
    expect(await todos.loadTodos(10), isFalse);

    database.todoName = 'Refreshed after reconnecting';
    connectivity.emit(ConnectivityResult.wifi);
    await recovered.future.timeout(const Duration(seconds: 2));
    expect(connection.status.value, ConnectionStatus.online);
    expect(todos.error.value, isNull);
    expect(todos.todosByCategory.value[10]!.single.name, 'Refreshed after reconnecting');
    expect(instantReloads, 1);

    database.todoName = 'Refreshed by manual retry';
    await sync.retry();
    expect(todos.todosByCategory.value[10]!.single.name, 'Refreshed by manual retry');
    expect(instantReloads, 2);
    await sync.dispose();
    await connection.dispose();
    await connectivity.events.close();
    await databaseEvents.close();
  });
}

class _Connectivity extends Fake implements Connectivity {
  final events = StreamController<List<ConnectivityResult>>.broadcast();
  ConnectivityResult current = ConnectivityResult.wifi;

  void emit(ConnectivityResult result) {
    current = result;
    events.add([result]);
  }

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => [current];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => events.stream;
}

class _Database extends Fake implements SupaDatabaseManager {
  _Database(this.events);

  final StreamController<PostgresChangePayload> events;
  bool failNextTodoRead = false;
  String todoName = 'Original';

  @override
  Stream<PostgresChangePayload> subscribeToTableChanges<T>(TableData<T> tableData) => events.stream;

  @override
  Future<Result<List<T>>> readEntries<T>(TableData<T> tableData) async =>
      Result.success([const TodoFile(id: 1, name: 'Inbox')].cast<T>());

  @override
  Future<Result<List<T>>> readEntriesWhere<T>(TableData<T> tableData, String columnName, Object value) async {
    if (tableData is CategoryTableData) {
      return Result.success([const Category(id: 10, name: 'Tasks', todoFileId: 1)].cast<T>());
    }
    if (failNextTodoRead) {
      failNextTodoRead = false;
      return Result.failure(TimeoutException('Offline'));
    }
    return Result.success([Todo(id: 100, name: todoName, categoryId: 10, todoFileId: 1)].cast<T>());
  }
}

class _DeviceState extends DeviceWorkspaceStateRepository {
  _DeviceState() : super(currentUserId: () => 'test-user');

  @override
  Future<bool> hasWorkspaceState() async => true;

  @override
  Future<PersistedWorkspaceState> getWorkspaceState() async =>
      const PersistedWorkspaceState(openFileIds: [1], selectedFileId: 1);

  @override
  Future<void> saveWorkspaceState({required List<int> openFileIds,
    required int? selectedFileId,
    required Map<int, PersistedWorkspaceSelection> selectionsByFile}) async {}
}
