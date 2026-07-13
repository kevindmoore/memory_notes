import 'dart:convert';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:lumberdash/lumberdash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supa_manager/supa_manager.dart';

import 'models.dart';

// ---------------------------------------------------------------------------
// TodoFileRepository
// ---------------------------------------------------------------------------

class TodoFileRepository {
  final SupaDatabaseManager _db;
  final _tableData = TodoFileTableData();

  TodoFileRepository(this._db);

  Future<List<TodoFile>> getAll() async {
    final result = await _db.readEntries(_tableData);
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
    final result = await _db.addEntry(_tableData, entry);
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
    final result = await _db.updateTableEntry(_tableData, entry);
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
    final result = await _db.updateTableEntryWhere<TodoFile>(
      _tableData,
      {'last_updated': timestamp.toIso8601String()},
      [SelectEntry.and('id', '$id')],
    );
    switch (result) {
      case Success():
        return true;
      default:
        logError('TodoFileRepository.touchLastUpdated failed');
        return false;
    }
  }

  Future<void> delete(int id) => _db.deleteTableEntryWhere(_tableData, 'id', id);
}

// ---------------------------------------------------------------------------
// CategoryRepository
// ---------------------------------------------------------------------------

class CategoryRepository {
  final SupaDatabaseManager _db;
  final _tableData = CategoryTableData();

  CategoryRepository(this._db);

  Future<List<Category>> getByTodoFile(int todoFileId) async {
    final result = await _db.readEntriesWhere(
      _tableData,
      todoFileIdName,
      todoFileId,
    );
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
    final result = await _db.addEntry(_tableData, entry);
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
    final result = await _db.updateTableEntry(_tableData, entry);
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
    final result = await _db.updateTableEntryWhere<Category>(
      _tableData,
      {'last_updated': timestamp.toIso8601String()},
      [SelectEntry.and('id', '$id')],
    );
    switch (result) {
      case Success():
        return true;
      default:
        logError('CategoryRepository.touchLastUpdated failed');
        return false;
    }
  }

  Future<void> delete(int id) => _db.deleteTableEntryWhere(_tableData, 'id', id);
}

// ---------------------------------------------------------------------------
// TodoRepository
// ---------------------------------------------------------------------------

class TodoRepository {
  final SupaDatabaseManager _db;
  final _tableData = TodoTableData();

  TodoRepository(this._db);

  Future<List<Todo>> getByCategory(int categoryId) async {
    final result = await _db.readEntriesWhere(
      _tableData,
      categoryIdName,
      categoryId,
    );
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
    final result = await _db.addEntry(_tableData, entry);
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
    final result = await _db.updateTableEntry(_tableData, entry);
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
    final result = await _db.updateTableEntryWhere<Todo>(
      _tableData,
      {'last_updated': timestamp.toIso8601String()},
      [SelectEntry.and('id', '$id')],
    );
    switch (result) {
      case Success():
        return true;
      default:
        logError('TodoRepository.touchLastUpdated failed');
        return false;
    }
  }

  Future<void> delete(int id) => _db.deleteTableEntryWhere(_tableData, 'id', id);
}

// ---------------------------------------------------------------------------
// InstantNoteRepository
// ---------------------------------------------------------------------------

class InstantNoteRepository {
  final SupaDatabaseManager _db;
  final _tableData = InstantNoteTableData();

  InstantNoteRepository(this._db);

  Future<List<InstantNote>> getAll() async {
    final result = await _db.readEntries(_tableData);
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
    final result = await _db.addEntry(_tableData, entry);
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
    final result = await _db.updateTableEntry(_tableData, entry);
    switch (result) {
      case Success(data: final data):
        return data;
      default:
        logError('InstantNoteRepository.update failed');
        return null;
    }
  }

  Future<void> delete(int id) => _db.deleteTableEntryWhere(_tableData, 'id', id);
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

class CurrentStateRepository {
  final SupaDatabaseManager _db;
  final _tableData = CurrentStateTableData();

  CurrentStateRepository(this._db);

  static const _workspaceStateVersion = 2;

  Future<CurrentState?> getCurrentState() async {
    final currentUserId = _db.client.auth.currentUser?.id;
    if (currentUserId == null) {
      return null;
    }

    final result = await _db.readEntriesWhere(
      _tableData,
      userIdFieldName,
      currentUserId,
    );
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
    final filesString = jsonEncode(<String, dynamic>{
      'version': _workspaceStateVersion,
      'openFileIds': fileIds,
    });
    final currentState = await getCurrentState();

    if (currentState == null) {
      final result = await _db.addEntry(
        _tableData,
        CurrentStateTableEntry(CurrentState(currentFiles: filesString)),
      );
      switch (result) {
        case Success():
          return;
        case Failure(error: final error):
          logError('CurrentStateRepository.saveCurrentFileIds add: $error');
        case ErrorMessage(message: final message, code: _):
          logError('CurrentStateRepository.saveCurrentFileIds add: $message');
      }
      return;
    }

    final result = await _db.updateTableEntry(
      _tableData,
      CurrentStateTableEntry(
        currentState.copyWith(
          currentFiles: filesString,
          lastUpdated: DateTime.now(),
        ),
      ),
    );
    switch (result) {
      case Success():
        return;
      case Failure(error: final error):
        logError('CurrentStateRepository.saveCurrentFileIds update: $error');
      case ErrorMessage(message: final message, code: _):
        logError('CurrentStateRepository.saveCurrentFileIds update: $message');
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

  Future<PersistedWorkspaceState> getWorkspaceState() async {
    final prefs = await _instance;
    final workspaceState = _decodeWorkspaceState(prefs.getString(_storageKey));
    if (_hasWorkspaceStateContent(workspaceState) || _storageKey == _storageKeyPrefix) {
      return workspaceState;
    }

    return _decodeWorkspaceState(prefs.getString(_storageKeyPrefix));
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

  bool _hasWorkspaceStateContent(PersistedWorkspaceState state) {
    return state.openFileIds.isNotEmpty ||
        state.selectedFileId != null ||
        state.selectionsByFile.isNotEmpty;
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

  Future<SharedPreferences> get _instance async => prefs ??= await SharedPreferences.getInstance();

  String get _storageKey {
    final userId = currentUserId();
    return userId == null ? _storageKeyPrefix : '${_storageKeyPrefix}_$userId';
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
