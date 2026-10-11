import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:lumberdash/lumberdash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supa_manager/supa_manager.dart';

import 'package:memory_notes/core/services/connection_service.dart';

import 'models.dart';

Future<Result<T>> _request<T>(
  Future<Result<T>> Function() operation,
  ConnectionService? connection,
) => connection == null
    ? operation().timeout(ConnectionService.requestTimeout)
    : connection.run(operation);

void _requireSuccess<T>(Result<T> result) {
  switch (result) {
    case Success():
      return;
    case Failure(error: final error):
      throw error;
    case ErrorMessage(message: final message):
      throw StateError(message ?? 'Request failed');
  }
}

// ---------------------------------------------------------------------------
// TodoFileRepository
// ---------------------------------------------------------------------------

class TodoFileRepository {
  final SupaDatabaseManager _db;
  final _tableData = TodoFileTableData();

  TodoFileRepository(this._db, {this.connection});

  final ConnectionService? connection;

  Future<List<TodoFile>> getAll() async {
    final result = await _request(() => _db.readEntries(_tableData), connection);
    switch (result) {
      case Success(data: final data):
        return data;
      case Failure(error: final error):
        logError('TodoFileRepository.getAll: $error');
        throw error;
      case ErrorMessage(message: final message, code: _):
        logError('TodoFileRepository.getAll: $message');
        throw StateError(message ?? 'Todo file read failed');
    }
  }

  Future<TodoFile?> add(String name) async {
    final entry = TodoFileTableEntry(TodoFile(name: name));
    final result = await _request(() => _db.addEntry(_tableData, entry), connection);
    switch (result) {
      case Success(data: final data):
        return data;
      default:
        logError('TodoFileRepository.add failed');
        return null;
    }
  }

  Future<TodoFile?> update(TodoFile file) async {
    final entry = TodoFileTableEntry(file);
    final result = await _request(() => _db.updateTableEntry(_tableData, entry), connection);
    switch (result) {
      case Success(data: final data):
        return data;
      default:
        logError('TodoFileRepository.update failed');
        return null;
    }
  }

  Future<bool> touchLastUpdated(
    int id,
    DateTime timestamp,
  ) async {
    final result = await _request(() => _db.updateTableEntryWhere<TodoFile>(
      _tableData,
      {'last_updated': timestamp.toIso8601String()},
      [SelectEntry.and('id', '$id')],
    ), connection);
    switch (result) {
      case Success():
        return true;
      default:
        logError('TodoFileRepository.touchLastUpdated failed');
        return false;
    }
  }

  Future<void> delete(int id) async {
    final result = await _request(
      () => _db.deleteTableEntryWhere(_tableData, 'id', id), connection,
    );
    _requireSuccess(result);
  }
}

// ---------------------------------------------------------------------------
// CategoryRepository
// ---------------------------------------------------------------------------

class CategoryRepository {
  final SupaDatabaseManager _db;
  final _tableData = CategoryTableData();

  CategoryRepository(this._db, {this.connection});

  final ConnectionService? connection;

  Future<List<Category>> getByTodoFile(int todoFileId) async {
    final result = await _request(() => _db.readEntriesWhere(
      _tableData,
      todoFileIdName,
      todoFileId,
    ), connection);
    switch (result) {
      case Success(data: final data):
        return data;
      case Failure(error: final error):
        logError('CategoryRepository.getByTodoFile: $error');
        throw error;
      case ErrorMessage(message: final message, code: _):
        logError('CategoryRepository.getByTodoFile: $message');
        throw StateError(message ?? 'Category read failed');
    }
  }

  Future<Category?> add(Category category, int todoFileId) async {
    final entry = CategoryTableEntry(category, todoFileId);
    final result = await _request(() => _db.addEntry(_tableData, entry), connection);
    switch (result) {
      case Success(data: final data):
        return data;
      default:
        logError('CategoryRepository.add failed');
        return null;
    }
  }

  Future<Category?> update(Category category, int todoFileId) async {
    final entry = CategoryTableEntry(category, todoFileId);
    final result = await _request(() => _db.updateTableEntry(_tableData, entry), connection);
    switch (result) {
      case Success(data: final data):
        return data;
      default:
        logError('CategoryRepository.update failed');
        return null;
    }
  }

  Future<bool> touchLastUpdated(
    int id,
    DateTime timestamp,
  ) async {
    final result = await _request(() => _db.updateTableEntryWhere<Category>(
      _tableData,
      {'last_updated': timestamp.toIso8601String()},
      [SelectEntry.and('id', '$id')],
    ), connection);
    switch (result) {
      case Success():
        return true;
      default:
        logError('CategoryRepository.touchLastUpdated failed');
        return false;
    }
  }

  Future<void> delete(int id) async {
    final result = await _request(
      () => _db.deleteTableEntryWhere(_tableData, 'id', id), connection,
    );
    _requireSuccess(result);
  }
}

// ---------------------------------------------------------------------------
// TodoRepository
// ---------------------------------------------------------------------------

class TodoRepository {
  final SupaDatabaseManager _db;
  final _tableData = TodoTableData();

  TodoRepository(this._db, {this.connection});

  final ConnectionService? connection;

  Future<List<Todo>> getByCategory(int categoryId) async {
    final result = await _request(() => _db.readEntriesWhere(
      _tableData,
      categoryIdName,
      categoryId,
    ), connection);
    switch (result) {
      case Success(data: final data):
        final sorted = List<Todo>.from(data)..sort((a, b) => a.order.compareTo(b.order));
        return sorted;
      case Failure(error: final error):
        logError('TodoRepository.getByCategory: $error');
        throw error;
      case ErrorMessage(message: final message, code: _):
        logError('TodoRepository.getByCategory: $message');
        throw StateError(message ?? 'Todo read failed');
    }
  }

  Future<Todo?> add(Todo todo, int todoFileId, int categoryId) async {
    final entry = TodoTableEntry(todo, todoFileId, categoryId);
    final result = await _request(() => _db.addEntry(_tableData, entry), connection);
    switch (result) {
      case Success(data: final data):
        return data;
      default:
        logError('TodoRepository.add failed');
        return null;
    }
  }

  Future<Todo?> update(Todo todo, int todoFileId, int categoryId) async {
    final entry = TodoTableEntry(todo, todoFileId, categoryId);
    final result = await _request(() => _db.updateTableEntry(_tableData, entry), connection);
    switch (result) {
      case Success(data: final data):
        return data;
      default:
        logError('TodoRepository.update failed');
        return null;
    }
  }

  Future<bool> touchLastUpdated(
    int id,
    DateTime timestamp,
  ) async {
    final result = await _request(() => _db.updateTableEntryWhere<Todo>(
      _tableData,
      {'last_updated': timestamp.toIso8601String()},
      [SelectEntry.and('id', '$id')],
    ), connection);
    switch (result) {
      case Success():
        return true;
      default:
        logError('TodoRepository.touchLastUpdated failed');
        return false;
    }
  }

  Future<void> delete(int id) async {
    final result = await _request(
      () => _db.deleteTableEntryWhere(_tableData, 'id', id), connection,
    );
    _requireSuccess(result);
  }
}

// ---------------------------------------------------------------------------
// InstantNoteRepository
// ---------------------------------------------------------------------------

class InstantNoteRepository {
  final SupaDatabaseManager _db;
  final _tableData = InstantNoteTableData();

  InstantNoteRepository(this._db, {this.connection});

  final ConnectionService? connection;

  Future<List<InstantNote>> getAll() async {
    final result = await _request(() => _db.readEntries(_tableData), connection);
    switch (result) {
      case Success(data: final data):
        final sorted = List<InstantNote>.from(data)
          ..sort((a, b) {
            final left = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final right = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return right.compareTo(left);
          });
        return sorted;
      case Failure(error: final error):
        logError('InstantNoteRepository.getAll: $error');
        throw error;
      case ErrorMessage(message: final message, code: _):
        logError('InstantNoteRepository.getAll: $message');
        throw StateError(message ?? 'Instant note read failed');
    }
  }

  Future<InstantNote?> add(String notes) async {
    final now = DateTime.now();
    final entry = InstantNoteTableEntry(
      InstantNote(
        notes: notes,
        lastUpdated: now,
        createdAt: now,
      ),
    );
    final result = await _request(() => _db.addEntry(_tableData, entry), connection);
    switch (result) {
      case Success(data: final data):
        return data;
      default:
        logError('InstantNoteRepository.add failed');
        return null;
    }
  }

  Future<InstantNote?> update(InstantNote instantNote) async {
    final entry = InstantNoteTableEntry(instantNote);
    final result = await _request(() => _db.updateTableEntry(_tableData, entry), connection);
    switch (result) {
      case Success(data: final data):
        return data;
      default:
        logError('InstantNoteRepository.update failed');
        return null;
    }
  }

  Future<void> delete(int id) async {
    final result = await _request(
      () => _db.deleteTableEntryWhere(_tableData, 'id', id), connection,
    );
    _requireSuccess(result);
  }
}

// ---------------------------------------------------------------------------
// CurrentStateRepository
// ---------------------------------------------------------------------------

class PersistedWorkspaceSelection {
  const PersistedWorkspaceSelection({
    this.categoryId,
    this.todoId,
    this.todoPath = const <int>[],
    this.desktopScrollOffset = 0,
  });

  final int? categoryId;
  final int? todoId;
  final List<int> todoPath;
  final double desktopScrollOffset;
}

class PersistedWorkspaceState {
  const PersistedWorkspaceState({
    this.openFileIds = const <int>[],
    this.selectedFileId,
    this.selectionsByFile = const <int, PersistedWorkspaceSelection>{},
  });

  final List<int> openFileIds;
  final int? selectedFileId;
  final Map<int, PersistedWorkspaceSelection> selectionsByFile;
}

class DesktopWorkspaceLayout {
  const DesktopWorkspaceLayout({
    this.sidebarWidth = defaultSidebarWidth,
    this.categoryRailWidth = defaultCategoryRailWidth,
    this.todoDrilldownWidth = defaultTodoDrilldownWidth,
  });

  static const defaultSidebarWidth = 360.0;
  static const defaultCategoryRailWidth = 320.0;
  static const defaultTodoDrilldownWidth = 360.0;

  final double sidebarWidth;
  final double categoryRailWidth;
  final double todoDrilldownWidth;
}

class CurrentStateRepository {
  final SupaDatabaseManager _db;
  final _tableData = CurrentStateTableData();

  CurrentStateRepository(this._db, {this.connection});

  final ConnectionService? connection;

  static const _workspaceStateVersion = 2;

  Future<CurrentState?> getCurrentState() async {
    final currentUserId = _db.client.auth.currentUser?.id;
    if (currentUserId == null) {
      return null;
    }

    final result = await _request(() => _db.readEntriesWhere(
      _tableData,
      userIdFieldName,
      currentUserId,
    ), connection);
    switch (result) {
      case Success(data: final data):
        return selectLatestCurrentState(
          data,
          currentUserId: currentUserId,
        );
      case Failure(error: final error):
        logError('CurrentStateRepository.getCurrentState: $error');
      case ErrorMessage(message: final message, code: _):
        logError('CurrentStateRepository.getCurrentState: $message');
    }
    return null;
  }

  @visibleForTesting
  static CurrentState? selectLatestCurrentState(
    List<CurrentState> states, {
    String? currentUserId,
  }) {
    final statesForCurrentUser = currentUserId == null
        ? states
        : states.where((state) => state.userId == currentUserId).toList(growable: false);
    if (statesForCurrentUser.isEmpty) {
      return null;
    }

    final sortedStates = List<CurrentState>.from(statesForCurrentUser)
      ..sort((a, b) {
        final lastUpdatedComparison = _compareCurrentStateTimestamps(
          b.lastUpdated,
          a.lastUpdated,
        );
        if (lastUpdatedComparison != 0) {
          return lastUpdatedComparison;
        }
        return (b.id ?? 0).compareTo(a.id ?? 0);
      });
    return sortedStates.first;
  }

  static int _compareCurrentStateTimestamps(DateTime? left, DateTime? right) {
    if (left == null && right == null) return 0;
    if (left == null) return -1;
    if (right == null) return 1;
    return left.compareTo(right);
  }

  Future<PersistedWorkspaceState> getWorkspaceState() async {
    final currentState = await getCurrentState();
    final rawValue = currentState?.currentFiles.trim() ?? '';
    if (rawValue.isEmpty) {
      return const PersistedWorkspaceState();
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Workspace state is not a JSON object.');
      }

      final openFileIds = _parseIntList(decoded['openFileIds']);
      final selectedFileId = _parseInt(decoded['selectedFileId']);
      final rawSelections = decoded['selectionsByFile'];
      final selectionsByFile = <int, PersistedWorkspaceSelection>{};
      if (rawSelections is Map<String, dynamic>) {
        for (final entry in rawSelections.entries) {
          final fileId = int.tryParse(entry.key);
          final selection = _parseSelection(entry.value);
          if (fileId == null || selection == null) continue;
          selectionsByFile[fileId] = selection;
        }
      }

      return PersistedWorkspaceState(
        openFileIds: openFileIds,
        selectedFileId: selectedFileId,
        selectionsByFile: selectionsByFile,
      );
    } catch (_) {
      return PersistedWorkspaceState(
        openFileIds: rawValue
            .split(',')
            .map((value) => int.tryParse(value.trim()))
            .whereType<int>()
            .toList(),
      );
    }
  }

  Future<List<int>> getCurrentFileIds() async {
    final workspaceState = await getWorkspaceState();
    return workspaceState.openFileIds;
  }

  Future<void> saveCurrentFileIds(List<int> fileIds) async {
    final existingState = await getWorkspaceState();
    await saveWorkspaceState(
      openFileIds: fileIds,
      selectedFileId: existingState.selectedFileId,
      selectionsByFile: existingState.selectionsByFile,
    );
  }

  Future<void> saveWorkspaceState({
    required List<int> openFileIds,
    required int? selectedFileId,
    required Map<int, PersistedWorkspaceSelection> selectionsByFile,
  }) async {
    final normalizedSelections = <String, Map<String, dynamic>>{};
    for (final entry in selectionsByFile.entries) {
      normalizedSelections['${entry.key}'] = <String, dynamic>{
        if (entry.value.categoryId != null) 'categoryId': entry.value.categoryId,
        if (entry.value.todoId != null) 'todoId': entry.value.todoId,
        'todoPath': entry.value.todoPath,
        'desktopScrollOffset': entry.value.desktopScrollOffset,
      };
    }
    final filesString = jsonEncode(<String, dynamic>{
      'version': _workspaceStateVersion,
      'openFileIds': openFileIds,
      'selectedFileId': ?selectedFileId,
      'selectionsByFile': normalizedSelections,
    });
    final currentState = await getCurrentState();

    if (currentState == null) {
      final result = await _request(() => _db.addEntry(
        _tableData,
        CurrentStateTableEntry(CurrentState(currentFiles: filesString)),
      ), connection);
      switch (result) {
        case Success():
          return;
        case Failure(error: final error):
          logError('CurrentStateRepository.saveWorkspaceState add: $error');
        case ErrorMessage(message: final message, code: _):
          logError('CurrentStateRepository.saveWorkspaceState add: $message');
      }
      return;
    }

    final result = await _request(() => _db.updateTableEntry(
      _tableData,
      CurrentStateTableEntry(
        currentState.copyWith(
          currentFiles: filesString,
          lastUpdated: DateTime.now(),
        ),
      ),
    ), connection);
    switch (result) {
      case Success():
        return;
      case Failure(error: final error):
        logError('CurrentStateRepository.saveWorkspaceState update: $error');
      case ErrorMessage(message: final message, code: _):
        logError('CurrentStateRepository.saveWorkspaceState update: $message');
    }
  }
}

class DeviceWorkspaceStateRepository {
  DeviceWorkspaceStateRepository({
    required this.currentUserId,
    this.prefs,
  });

  final String? Function() currentUserId;
  SharedPreferences? prefs;

  static const _workspaceStateVersion = 2;
  static const _storageKeyPrefix = 'device_workspace_state';
  static const _desktopWorkspaceLayoutStorageKeyPrefix = 'desktop_workspace_layout';

  Future<PersistedWorkspaceState> getWorkspaceState() async {
    final prefs = await _instance;
    final rawWorkspaceState = prefs.getString(_storageKey);
    if (rawWorkspaceState != null && rawWorkspaceState.trim().isNotEmpty) {
      return _decodeWorkspaceState(rawWorkspaceState);
    }
    if (_storageKey == _storageKeyPrefix) {
      return const PersistedWorkspaceState();
    }

    return _decodeWorkspaceState(prefs.getString(_storageKeyPrefix));
  }

  Future<bool> hasWorkspaceState() async {
    final prefs = await _instance;
    final rawWorkspaceState = prefs.getString(_storageKey);
    if (rawWorkspaceState != null && rawWorkspaceState.trim().isNotEmpty) {
      return true;
    }
    if (_storageKey == _storageKeyPrefix) {
      return false;
    }
    final legacyWorkspaceState = prefs.getString(_storageKeyPrefix);
    return legacyWorkspaceState != null && legacyWorkspaceState.trim().isNotEmpty;
  }

  PersistedWorkspaceState _decodeWorkspaceState(String? rawValue) {
    if (rawValue == null || rawValue.trim().isEmpty) {
      return const PersistedWorkspaceState();
    }
    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Workspace state is not a JSON object.');
      }

      final openFileIds = _parseIntList(decoded['openFileIds']);
      final selectedFileId = _parseInt(decoded['selectedFileId']);
      final rawSelections = decoded['selectionsByFile'];
      final selectionsByFile = <int, PersistedWorkspaceSelection>{};
      if (rawSelections is Map<String, dynamic>) {
        for (final entry in rawSelections.entries) {
          final fileId = int.tryParse(entry.key);
          final selection = _parseSelection(entry.value);
          if (fileId == null || selection == null) continue;
          selectionsByFile[fileId] = selection;
        }
      }

      return PersistedWorkspaceState(
        openFileIds: openFileIds,
        selectedFileId: selectedFileId,
        selectionsByFile: selectionsByFile,
      );
    } catch (_) {
      return const PersistedWorkspaceState();
    }
  }

  Future<void> saveWorkspaceState({
    required List<int> openFileIds,
    required int? selectedFileId,
    required Map<int, PersistedWorkspaceSelection> selectionsByFile,
  }) async {
    final prefs = await _instance;
    final normalizedSelections = <String, Map<String, dynamic>>{};
    for (final entry in selectionsByFile.entries) {
      normalizedSelections['${entry.key}'] = <String, dynamic>{
        if (entry.value.categoryId != null) 'categoryId': entry.value.categoryId,
        if (entry.value.todoId != null) 'todoId': entry.value.todoId,
        'todoPath': entry.value.todoPath,
        'desktopScrollOffset': entry.value.desktopScrollOffset,
      };
    }
    final filesString = jsonEncode(<String, dynamic>{
      'version': _workspaceStateVersion,
      'openFileIds': openFileIds,
      'selectedFileId': ?selectedFileId,
      'selectionsByFile': normalizedSelections,
    });
    await prefs.setString(_storageKey, filesString);
  }

  Future<DesktopWorkspaceLayout> getDesktopWorkspaceLayout() async {
    final prefs = await _instance;
    final rawLayout = prefs.getString(_desktopWorkspaceLayoutStorageKey);
    if (rawLayout == null || rawLayout.trim().isEmpty) {
      return const DesktopWorkspaceLayout();
    }

    try {
      final decoded = jsonDecode(rawLayout);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Desktop workspace layout is not a JSON object.');
      }
      return DesktopWorkspaceLayout(
        sidebarWidth: _parseDouble(decoded['sidebarWidth']) ?? DesktopWorkspaceLayout.defaultSidebarWidth,
        categoryRailWidth:
            _parseDouble(decoded['categoryRailWidth']) ?? DesktopWorkspaceLayout.defaultCategoryRailWidth,
        todoDrilldownWidth:
            _parseDouble(decoded['todoDrilldownWidth']) ?? DesktopWorkspaceLayout.defaultTodoDrilldownWidth,
      );
    } catch (_) {
      return const DesktopWorkspaceLayout();
    }
  }

  Future<void> saveDesktopWorkspaceLayout(DesktopWorkspaceLayout layout) async {
    final prefs = await _instance;
    final rawLayout = jsonEncode(<String, double>{
      'sidebarWidth': layout.sidebarWidth,
      'categoryRailWidth': layout.categoryRailWidth,
      'todoDrilldownWidth': layout.todoDrilldownWidth,
    });
    await prefs.setString(_desktopWorkspaceLayoutStorageKey, rawLayout);
  }

  Future<SharedPreferences> get _instance async => prefs ??= await SharedPreferences.getInstance();

  String get _storageKey {
    final userId = currentUserId();
    return userId == null ? _storageKeyPrefix : '${_storageKeyPrefix}_$userId';
  }

  String get _desktopWorkspaceLayoutStorageKey {
    final userId = currentUserId();
    return userId == null
        ? _desktopWorkspaceLayoutStorageKeyPrefix
        : '${_desktopWorkspaceLayoutStorageKeyPrefix}_$userId';
  }
}

int? _parseInt(Object? value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

List<int> _parseIntList(Object? value) {
  if (value is! List) return const <int>[];
  return value.map(_parseInt).whereType<int>().toList(growable: false);
}

PersistedWorkspaceSelection? _parseSelection(Object? value) {
  if (value is! Map<String, dynamic>) return null;
  final todoPath = _parseIntList(value['todoPath']);
  final todoId = _parseInt(value['todoId']) ?? (todoPath.isEmpty ? null : todoPath.last);
  return PersistedWorkspaceSelection(
    categoryId: _parseInt(value['categoryId']),
    todoId: todoId,
    todoPath: todoPath,
    desktopScrollOffset: _parseDouble(value['desktopScrollOffset']) ?? 0,
  );
}

double? _parseDouble(Object? value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
