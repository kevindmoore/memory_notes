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
  bool _connectivityHintOnline = true;
  bool _realtimeRecoveryInFlight = false;
  bool _recoveryReloadInFlight = false;
  DateTime? _lastRecoveryReloadAt;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    _subscribeToRealtimeTables();

    _connectivityHintOnline = hasNetworkConnection(await connectivity.checkConnectivity());
    _connectivitySubscription =
        connectivity.onConnectivityChanged.listen(_handleConnectivityChanged, onError: (error) {
      logError('NotesSyncService connectivity stream error: $error');
    });
  }

  Future<void> dispose() async {
    await _cancelRealtimeSubscriptions();
    await _connectivitySubscription?.cancel();
    _recoveryRetryTimer?.cancel();
    _initialized = false;
  }

  Future<void> handleAppResumed() async {
    if (!_initialized) return;
    await _performRecoveryReload(reason: 'app resumed');
  }

  Future<void> handleRealtimeSocketClosed() async {
    if (!_initialized) return;
    await _recoverRealtime(reason: 'closed realtime socket');
  }

  void _subscribeToRealtimeTables() {
    _todoFileSubscription = database
        .subscribeToTableChanges(TodoFileTableData())
        .listen(_handleFileChange, onError: (error) {
      _handleRealtimeStreamError(error, reason: 'file stream error');
    });

    _categorySubscription = database
        .subscribeToTableChanges(CategoryTableData())
        .listen(_handleCategoryChange, onError: (error) {
      _handleRealtimeStreamError(error, reason: 'category stream error');
    });

    _todoSubscription = database.subscribeToTableChanges(TodoTableData()).listen(_handleTodoChange,
        onError: (error) {
      _handleRealtimeStreamError(error, reason: 'todo stream error');
    });
  }

  Future<void> _cancelRealtimeSubscriptions() async {
    await _todoFileSubscription?.cancel();
    await _categorySubscription?.cancel();
    await _todoSubscription?.cancel();
    _todoFileSubscription = null;
    _categorySubscription = null;
    _todoSubscription = null;
  }

  void _handleRealtimeStreamError(Object error, {required String reason}) {
    logError('NotesSyncService $reason: $error');
    unawaited(_recoverRealtime(reason: reason));
  }

  Future<void> _recoverRealtime({required String reason}) async {
    if (_realtimeRecoveryInFlight) {
      return;
    }

    _realtimeRecoveryInFlight = true;
    try {
      await _cancelRealtimeSubscriptions();
      if (!_initialized) return;
      _subscribeToRealtimeTables();
      await _performRecoveryReload(reason: reason, ignoreCooldown: true);
    } catch (error) {
      logError('NotesSyncService realtime recovery failed ($reason): $error');
      _scheduleRecoveryRetry(reason: reason);
    } finally {
      _realtimeRecoveryInFlight = false;
    }
  }

  Future<void> _handleFileChange(dynamic payload) async {
    if (_shouldSkipFileRefresh(payload)) {
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
    if (_shouldSkipCategoryRefresh(payload)) {
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
    if (_shouldSkipTodoRefresh(payload)) {
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
    final hadNetworkConnection = _connectivityHintOnline;
    _connectivityHintOnline = nextHasNetworkConnection;

    if (!hadNetworkConnection && nextHasNetworkConnection) {
      await _performRecoveryReload(reason: 'connectivity restored');
      return;
    }

    if (!nextHasNetworkConnection) {
      logMessage(
        'NotesSyncService connectivity hint reported no network; waiting for a real backend probe before treating this as offline',
      );
      _scheduleRecoveryRetry(reason: 'connectivity hint reported offline');
      return;
    }

    _scheduleRecoveryRetry(reason: 'connectivity changed');
  }

  Future<void> _performRecoveryReload({
    required String reason,
    bool ignoreCooldown = false,
  }) async {
    if (_recoveryReloadInFlight) {
      return;
    }

    final nowValue = now();
    if (!ignoreCooldown &&
        _lastRecoveryReloadAt != null &&
        nowValue.difference(_lastRecoveryReloadAt!) < recoveryReloadCooldown) {
      return;
    }

    _connectivityHintOnline = hasNetworkConnection(await connectivity.checkConnectivity());

    final backendReachable = await _canReachBackend();
    if (!backendReachable) {
      _scheduleRecoveryRetry(reason: reason);
      return;
    }

    _recoveryReloadInFlight = true;
    try {
      await notesWorkspace.reloadAllFiles();
      _lastRecoveryReloadAt = now();
      _recoveryRetryTimer?.cancel();
      _recoveryRetryTimer = null;
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
        logError('NotesSyncService backend probe failed: $error');
        return false;
      case ErrorMessage(code: final code, message: final message):
        logError('NotesSyncService backend probe failed: [$code] $message');
        return false;
    }
  }

  void _scheduleRecoveryRetry({required String reason}) {
    if (!_initialized) return;
    if (_recoveryRetryTimer?.isActive ?? false) return;

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
