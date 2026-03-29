import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:lumberdash/lumberdash.dart';
import 'package:memory_notes/features/notes/application/category_controller.dart';
import 'package:memory_notes/features/notes/application/notes_query_service.dart';
import 'package:memory_notes/features/notes/application/notes_workspace_controller.dart';
import 'package:memory_notes/features/notes/application/notes_workspace_store.dart';
import 'package:memory_notes/features/notes/application/todo_controller.dart';
import 'package:memory_notes/features/notes/application/todo_file_controller.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:supa_manager/supa_manager.dart';

class NotesSyncService {
  NotesSyncService({
    required this.database,
    required this.query,
    required this.workspace,
    required this.notesWorkspace,
    required this.todoFiles,
    required this.categories,
    required this.todos,
    Connectivity? connectivity,
    DateTime Function()? now,
    this.recoveryReloadCooldown = const Duration(seconds: 5),
    this.recoveryRetryInterval = const Duration(seconds: 20),
  })  : connectivity = connectivity ?? Connectivity(),
        now = now ?? DateTime.now;

  final SupaDatabaseManager database;
  final NotesQueryService query;
  final NotesWorkspaceController workspace;
  final NotesWorkspaceStore notesWorkspace;
  final TodoFileController todoFiles;
  final CategoryController categories;
  final TodoController todos;
  final Connectivity connectivity;
  final DateTime Function() now;
  final Duration recoveryReloadCooldown;
  final Duration recoveryRetryInterval;

  StreamSubscription? _todoFileSubscription;
  StreamSubscription? _categorySubscription;
  StreamSubscription? _todoSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _recoveryRetryTimer;

  bool _initialized = false;
  bool _hasNetworkConnection = true;
  bool _recoveryReloadInFlight = false;
  DateTime? _lastRecoveryReloadAt;

  Future<void> initialize() async {
    if (_initialized) {
      logMessage('NotesSyncService initialize skipped: already initialized');
      return;
    }
    _initialized = true;

    _todoFileSubscription = database
        .subscribeToTableChanges(TodoFileTableData())
        .listen(_handleFileChange, onError: (error) {
      logError('NotesSyncService file stream error: $error');
      _scheduleRecoveryRetry(reason: 'file stream error');
    });

    _categorySubscription = database
        .subscribeToTableChanges(CategoryTableData())
        .listen(_handleCategoryChange, onError: (error) {
      logError('NotesSyncService category stream error: $error');
      _scheduleRecoveryRetry(reason: 'category stream error');
    });

    _todoSubscription = database.subscribeToTableChanges(TodoTableData()).listen(_handleTodoChange,
        onError: (error) {
      logError('NotesSyncService todo stream error: $error');
      _scheduleRecoveryRetry(reason: 'todo stream error');
    });

    _hasNetworkConnection = hasNetworkConnection(await connectivity.checkConnectivity());
    _connectivitySubscription =
        connectivity.onConnectivityChanged.listen(_handleConnectivityChanged, onError: (error) {
      logError('NotesSyncService connectivity stream error: $error');
    });
  }

  Future<void> dispose() async {
    await _todoFileSubscription?.cancel();
    await _categorySubscription?.cancel();
    await _todoSubscription?.cancel();
    await _connectivitySubscription?.cancel();
    _recoveryRetryTimer?.cancel();
    _initialized = false;
  }

  Future<void> handleAppResumed() async {
    if (!_initialized) return;
    await _performRecoveryReload(reason: 'app resumed');
  }

  Future<void> _handleFileChange(dynamic payload) async {
    logMessage('NotesSyncService file change: ${payload.eventType}');
    if (_shouldSkipFileRefresh(payload)) {
      logMessage(
        'NotesSyncService file change skipped: '
        'event=${payload.eventType}, '
        'fileId=${_readInt(payload.oldRecord, 'id', fallback: _readInt(payload.newRecord, 'id'))}',
      );
      return;
    }
    await todoFiles.load();
    final allFileIds = todoFiles.todoFiles.value
        .where((file) => file.id != null)
        .map((file) => file.id!)
        .toList(growable: false);

    final openFileIds =
        query.normalizeFileIds(workspace.openFileIds.value, todoFiles.todoFiles.value);
    workspace.setOpenFileIds(openFileIds);
    if (allFileIds.isNotEmpty) {
      await categories.loadCategoriesForFiles(allFileIds);
    }
    notesWorkspace.syncWorkspace();
    await notesWorkspace.persistCurrentFiles();
  }

  Future<void> _handleCategoryChange(dynamic payload) async {
    logMessage('NotesSyncService category change: ${payload.eventType}');
    if (_shouldSkipCategoryRefresh(payload)) {
      logMessage(
        'NotesSyncService category change skipped: '
        'event=${payload.eventType}, '
        'categoryId=${_readInt(payload.oldRecord, 'id', fallback: _readInt(payload.newRecord, 'id'))}',
      );
      return;
    }
    final fileId = _readInt(
      payload.newRecord,
      'todoFileId',
      fallback: _readInt(payload.oldRecord, 'todoFileId'),
    );

    if (fileId == null) {
      logMessage(
        'NotesSyncService category change missing todoFileId: '
        'event=${payload.eventType}, '
        'categoryId=${_readInt(payload.oldRecord, 'id', fallback: _readInt(payload.newRecord, 'id'))}. '
        'Reloading all loaded file categories.',
      );
      final allFileIds = todoFiles.todoFiles.value
          .where((file) => file.id != null)
          .map((file) => file.id!)
          .toList(growable: false);
      if (allFileIds.isNotEmpty) {
        await categories.loadCategoriesForFiles(allFileIds);
      }
      notesWorkspace.syncWorkspace();
      return;
    }

    await categories.loadCategories(fileId);
    notesWorkspace.syncWorkspace();
  }

  Future<void> _handleTodoChange(dynamic payload) async {
    logMessage('NotesSyncService todo change: ${payload.eventType}');
    if (_shouldSkipTodoRefresh(payload)) {
      logMessage(
        'NotesSyncService todo change skipped: '
        'event=${payload.eventType}, '
        'todoId=${_readInt(payload.oldRecord, 'id', fallback: _readInt(payload.newRecord, 'id'))}, '
        'categoryId=${_readInt(payload.oldRecord, 'categoryId', fallback: _readInt(payload.newRecord, 'categoryId'))}',
      );
      return;
    }
    final eventType = payload.eventType?.toString() ?? '';
    final categoryId = _readInt(
      payload.newRecord,
      'categoryId',
      fallback: _readInt(payload.oldRecord, 'categoryId'),
    );
    final todoId = _readInt(
      payload.newRecord,
      'id',
      fallback: _readInt(payload.oldRecord, 'id'),
    );
    final localTodo = query.findTodoById(
      todos.todosByCategory.value.values.expand((items) => items),
      todoId,
    );
    final resolvedCategoryId = categoryId ?? localTodo?.categoryId;

    if (resolvedCategoryId == null) {
      logMessage(
        'NotesSyncService todo change missing categoryId and no local todo match: '
        'event=$eventType, todoId=$todoId. Reloading all loaded categories.',
      );
      final loadedCategoryIds = todos.todosByCategory.value.keys.toList(growable: false);
      for (final loadedCategoryId in loadedCategoryIds) {
        await todos.loadTodos(loadedCategoryId);
      }
      notesWorkspace.syncWorkspace();
      return;
    }

    if (eventType.contains('delete')) {
      logMessage(
        'NotesSyncService processing todo delete: '
        'todoId=$todoId, categoryId=$resolvedCategoryId',
      );
      todos.removeTodoById(categoryId: resolvedCategoryId, todoId: todoId);
      await todos.loadTodos(resolvedCategoryId);
      notesWorkspace.syncWorkspace();
      return;
    }

    await todos.loadTodos(resolvedCategoryId);
    notesWorkspace.syncWorkspace();
  }

  bool _shouldSkipFileRefresh(dynamic payload) {
    final eventType = payload.eventType?.toString() ?? '';
    final fileId = _readInt(payload.oldRecord, 'id');
    final nextFileId = _readInt(
      payload.newRecord is Map<String, dynamic> ? payload.newRecord : const <String, dynamic>{},
      'id',
      fallback: fileId,
    );
    final localFile = query.findFileById(todoFiles.todoFiles.value, nextFileId);
    return shouldSkipFileRefresh(
      eventType: eventType,
      localFile: localFile,
      newRecord: payload.newRecord is Map<String, dynamic>
          ? Map<String, dynamic>.from(payload.newRecord)
          : null,
      deletedFileId: fileId,
    );
  }

  bool _shouldSkipCategoryRefresh(dynamic payload) {
    final eventType = payload.eventType?.toString() ?? '';
    final categoryId = _readInt(payload.oldRecord, 'id');
    final nextCategoryId = _readInt(
      payload.newRecord is Map<String, dynamic> ? payload.newRecord : const <String, dynamic>{},
      'id',
      fallback: categoryId,
    );
    final localCategory = query.findCategoryById(categories.categories.value, nextCategoryId);
    return shouldSkipCategoryRefresh(
      eventType: eventType,
      localCategory: localCategory,
      newRecord: payload.newRecord is Map<String, dynamic>
          ? Map<String, dynamic>.from(payload.newRecord)
          : null,
      deletedCategoryId: categoryId,
    );
  }

  bool _shouldSkipTodoRefresh(dynamic payload) {
    final eventType = payload.eventType?.toString() ?? '';
    final categoryId = _readInt(
      payload.newRecord,
      'categoryId',
      fallback: _readInt(payload.oldRecord, 'categoryId'),
    );
    final todoId = _readInt(
      payload.newRecord is Map<String, dynamic> ? payload.newRecord : const <String, dynamic>{},
      'id',
      fallback: _readInt(payload.oldRecord, 'id'),
    );
    final localTodo = categoryId == null
        ? query.findTodoById(
            todos.todosByCategory.value.values.expand((items) => items),
            todoId,
          )
        : query.findTodoById(
            query.todosForCategory(todos.todosByCategory.value, categoryId),
            todoId,
          );
    return shouldSkipTodoRefresh(
      eventType: eventType,
      localTodo: localTodo,
      newRecord: payload.newRecord is Map<String, dynamic>
          ? Map<String, dynamic>.from(payload.newRecord)
          : null,
      deletedTodoId: todoId,
    );
  }

  Future<void> _handleConnectivityChanged(List<ConnectivityResult> results) async {
    final nextHasNetworkConnection = hasNetworkConnection(results);
    final hadNetworkConnection = _hasNetworkConnection;
    _hasNetworkConnection = nextHasNetworkConnection;

    if (!hadNetworkConnection && nextHasNetworkConnection) {
      await _performRecoveryReload(reason: 'connectivity restored');
      return;
    }

    if (!nextHasNetworkConnection) {
      logMessage('NotesSyncService connectivity hint: offline');
      return;
    }

    _scheduleRecoveryRetry(reason: 'connectivity changed');
  }

  Future<void> _performRecoveryReload({required String reason}) async {
    if (_recoveryReloadInFlight) {
      logMessage('NotesSyncService recovery reload skipped: already in flight ($reason)');
      return;
    }

    final nowValue = now();
    if (_lastRecoveryReloadAt != null &&
        nowValue.difference(_lastRecoveryReloadAt!) < recoveryReloadCooldown) {
      logMessage('NotesSyncService recovery reload skipped: cooldown active ($reason)');
      return;
    }

    final hasConnectionHint = hasNetworkConnection(await connectivity.checkConnectivity());
    _hasNetworkConnection = hasConnectionHint;
    if (!hasConnectionHint) {
      logMessage('NotesSyncService recovery reload skipped: no local connection hint ($reason)');
      return;
    }

    final backendReachable = await _canReachBackend();
    if (!backendReachable) {
      logMessage('NotesSyncService recovery reload deferred: backend unreachable ($reason)');
      _scheduleRecoveryRetry(reason: reason);
      return;
    }

    _recoveryReloadInFlight = true;
    try {
      logMessage('NotesSyncService recovery reload started: $reason');
      await notesWorkspace.reloadAllFiles();
      _lastRecoveryReloadAt = now();
      _recoveryRetryTimer?.cancel();
      _recoveryRetryTimer = null;
      logMessage('NotesSyncService recovery reload completed: $reason');
    } catch (error) {
      logError('NotesSyncService recovery reload failed ($reason): $error');
      _scheduleRecoveryRetry(reason: reason);
    } finally {
      _recoveryReloadInFlight = false;
    }
  }

  Future<bool> _canReachBackend() async {
    final result = await database.readEntries(TodoFileTableData());
    switch (result) {
      case Success():
        return true;
      case Failure(error: final error):
        logMessage('NotesSyncService backend probe failed: $error');
        return false;
      case ErrorMessage(code: final code, message: final message):
        logMessage('NotesSyncService backend probe failed: [$code] $message');
        return false;
    }
  }

  void _scheduleRecoveryRetry({required String reason}) {
    if (!_initialized) return;
    if (_recoveryRetryTimer?.isActive ?? false) return;

    logMessage('NotesSyncService scheduling recovery retry: $reason');
    _recoveryRetryTimer = Timer.periodic(recoveryRetryInterval, (_) {
      _performRecoveryReload(reason: 'scheduled retry');
    });
  }

  @visibleForTesting
  static bool hasNetworkConnection(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }

  @visibleForTesting
  static bool shouldSkipFileRefresh({
    required String eventType,
    required TodoFile? localFile,
    required Map<String, dynamic>? newRecord,
    required int? deletedFileId,
  }) {
    if (eventType.contains('delete')) {
      return deletedFileId == null || localFile == null;
    }

    if (newRecord == null) {
      return false;
    }

    final remoteFile = TodoFile.fromJson(newRecord);
    return localFile == remoteFile;
  }

  @visibleForTesting
  static bool shouldSkipCategoryRefresh({
    required String eventType,
    required Category? localCategory,
    required Map<String, dynamic>? newRecord,
    required int? deletedCategoryId,
  }) {
    if (eventType.contains('delete')) {
      return deletedCategoryId == null || localCategory == null;
    }

    if (newRecord == null) {
      return false;
    }

    final remoteCategory = Category.fromJson(newRecord);
    return localCategory == remoteCategory;
  }

  @visibleForTesting
  static bool shouldSkipTodoRefresh({
    required String eventType,
    required Todo? localTodo,
    required Map<String, dynamic>? newRecord,
    required int? deletedTodoId,
  }) {
    if (eventType.contains('delete')) {
      return deletedTodoId == null || localTodo == null;
    }

    if (newRecord == null) {
      return false;
    }

    final remoteTodo = Todo.fromJson(newRecord);
    return localTodo == remoteTodo;
  }

  int? _readInt(
    Map<String, dynamic> json,
    String camelKey, {
    int? fallback,
  }) {
    final snakeKey = camelKey.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
    final value = json[camelKey] ?? json[snakeKey];
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return fallback;
  }
}
