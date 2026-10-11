import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_notes/core/services/connection_service.dart';
import 'package:memory_notes/features/notes/application/todo_file_controller.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/data/repositories.dart';
import 'package:supa_manager/supa_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Wi-Fi alone does not prove internet access; a successful request does', () async {
    final connection = ConnectionService();
    connection.updateConnectivity([ConnectivityResult.wifi]);
    expect(connection.status.value, ConnectionStatus.unknown);

    await connection.run(() async => const Result<int>.success(1));
    expect(connection.status.value, ConnectionStatus.online);

    await connection.run(() async => Result<int>.failure(
      DatabaseTemporarilyUnavailableException(TimeoutException('request stalled')),
    ));
    expect(connection.status.value, ConnectionStatus.unavailable);

    connection.updateConnectivity([ConnectivityResult.wifi]);
    expect(connection.status.value, ConnectionStatus.unavailable);
    await connection.run(() async => const Result<int>.success(1));
    expect(connection.status.value, ConnectionStatus.online);
  });

  test('airplane mode shows offline and an actual successful request clears it', () async {
    final connection = ConnectionService();
    connection.updateConnectivity([ConnectivityResult.none]);
    expect(connection.status.value, ConnectionStatus.offline);
    connection.reportFailure(TimeoutException('request stalled'));
    expect(connection.status.value, ConnectionStatus.offline);
    await connection.run(() async => const Result<int>.success(1));
    expect(connection.status.value, ConnectionStatus.online);
  });

  test('validation and authentication errors are not connection failures', () async {
    final connection = ConnectionService();
    await connection.run(() async => const Result<int>.success(1));
    await connection.run(() async => const Result<int>.failure(
      PostgrestException(message: 'Not permitted', code: '42501'),
    ));
    connection.reportFailure(const AuthException('Invalid login credentials'));
    expect(connection.status.value, ConnectionStatus.online);
    connection.reportFailure(const PostgrestException(message: 'Unavailable', code: '503'));
    expect(connection.status.value, ConnectionStatus.unavailable);
  });

  test('an older successful request cannot hide a newer failure', () async {
    final connection = ConnectionService();
    final pending = Completer<Result<int>>();
    final request = connection.run(() => pending.future);
    connection.reportFailure(TimeoutException('another request failed'));
    pending.complete(const Result.success(1));
    await request;
    expect(connection.status.value, ConnectionStatus.unavailable);
  });

  test('stalled loads stop, preserve existing notes, and ignore late results', () async {
    final connection = ConnectionService(timeout: const Duration(milliseconds: 5));
    final database = _Database();
    final controller = TodoFileController(TodoFileRepository(database, connection: connection));
    controller.todoFiles.value = const [TodoFile(id: 1, name: 'Already loaded')];
    final oldRead = Completer<Result<List<TodoFile>>>();
    database.read = oldRead.future;

    await controller.load();
    expect(controller.isLoading.value, isFalse);
    expect(controller.error.value, isNotNull);
    expect(controller.todoFiles.value.single.name, 'Already loaded');
    expect(connection.status.value, ConnectionStatus.unavailable);

    database.read = Future.value(const Result.success([TodoFile(id: 1, name: 'Fresh data')]));
    await controller.load();
    expect(controller.error.value, isNull);
    expect(connection.status.value, ConnectionStatus.online);
    oldRead.complete(const Result.success([TodoFile(id: 1, name: 'Stale data')]));
    await Future<void>.delayed(Duration.zero);
    expect(controller.todoFiles.value.single.name, 'Fresh data');
  });

  test('failed deletes are not silently treated as successful', () async {
    final repository = TodoFileRepository(_Database());
    await expectLater(repository.delete(1), throwsA(isA<DatabaseTemporarilyUnavailableException>()));
  });

  test('retry refreshes connectivity and prevents overlapping retries', () async {
    final connectivity = _Connectivity();
    final connection = ConnectionService(connectivity: connectivity);
    final pending = Completer<void>();
    var reloads = 0;
    final retry = connection.retry(() {
      reloads++;
      return pending.future;
    });
    await Future<void>.delayed(Duration.zero);
    await connection.retry(() async => reloads++);
    expect(reloads, 1);
    expect(connection.isRetrying.value, isTrue);
    pending.complete();
    await retry;
    expect(connection.isRetrying.value, isFalse);
    await connection.dispose();
  });
}

class _Connectivity extends Fake implements Connectivity {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => [ConnectivityResult.wifi];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => const Stream.empty();
}

class _Database extends Fake implements SupaDatabaseManager {
  Future<Result<List<TodoFile>>> read = Future.value(const Result.success([]));

  @override
  Future<Result<List<T>>> readEntries<T>(TableData<T> tableData) async {
    final result = await read;
    return switch (result) {
      Success(data: final data) => Result.success(data.cast<T>()),
      Failure(error: final error) => Result.failure(error),
      ErrorMessage(code: final code, message: final message) => Result.errorMessage(code, message),
    };
  }

  @override
  Future<Result<T?>> deleteTableEntryWhere<T>(TableData<T> tableData, String columnName, Object value) async {
    return Result.failure(DatabaseTemporarilyUnavailableException(TimeoutException('offline')));
  }
}
