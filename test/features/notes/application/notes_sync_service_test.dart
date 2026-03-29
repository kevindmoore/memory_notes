import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:memory_notes/features/notes/application/notes_sync_service.dart';
import 'package:memory_notes/features/notes/data/models.dart';

void main() {
  group('NotesSyncService refresh policy', () {
    test('skips file refresh for identical update echo', () {
      final localFile = TodoFile(
        id: 1,
        name: 'Inbox',
        lastUpdated: DateTime.parse('2026-03-21T10:00:00.000'),
      );

      final shouldSkip = NotesSyncService.shouldSkipFileRefresh(
        eventType: 'PostgresChangeEvent.update',
        localFile: localFile,
        newRecord: {
          'id': 1,
          'name': 'Inbox',
          'last_updated': '2026-03-21T10:00:00.000',
        },
        deletedFileId: null,
      );

      expect(shouldSkip, isTrue);
    });

    test('does not skip file refresh when remote update differs', () {
      final localFile = TodoFile(
        id: 1,
        name: 'Inbox',
        lastUpdated: DateTime.parse('2026-03-21T10:00:00.000'),
      );

      final shouldSkip = NotesSyncService.shouldSkipFileRefresh(
        eventType: 'PostgresChangeEvent.update',
        localFile: localFile,
        newRecord: {
          'id': 1,
          'name': 'Inbox Renamed',
          'last_updated': '2026-03-21T10:01:00.000',
        },
        deletedFileId: null,
      );

      expect(shouldSkip, isFalse);
    });

    test('skips category delete when category is already gone locally', () {
      final shouldSkip = NotesSyncService.shouldSkipCategoryRefresh(
        eventType: 'PostgresChangeEvent.delete',
        localCategory: null,
        newRecord: null,
        deletedCategoryId: 42,
      );

      expect(shouldSkip, isTrue);
    });

    test('skips todo refresh for identical update echo', () {
      final localTodo = Todo(
        id: 100,
        name: 'Buy milk',
        categoryId: 10,
        todoFileId: 1,
        notes: '2%',
        lastUpdated: DateTime.parse('2026-03-21T10:00:00.000'),
      );

      final shouldSkip = NotesSyncService.shouldSkipTodoRefresh(
        eventType: 'PostgresChangeEvent.update',
        localTodo: localTodo,
        newRecord: {
          'id': 100,
          'name': 'Buy milk',
          'categoryId': 10,
          'todoFileId': 1,
          'notes': '2%',
          'done': false,
          'visible': true,
          'expanded': false,
          'order': 0,
          'last_updated': '2026-03-21T10:00:00.000',
        },
        deletedTodoId: null,
      );

      expect(shouldSkip, isTrue);
    });

    test('does not skip todo refresh when remote todo changed', () {
      final localTodo = Todo(
        id: 100,
        name: 'Buy milk',
        categoryId: 10,
        todoFileId: 1,
        notes: '2%',
        lastUpdated: DateTime.parse('2026-03-21T10:00:00.000'),
      );

      final shouldSkip = NotesSyncService.shouldSkipTodoRefresh(
        eventType: 'PostgresChangeEvent.update',
        localTodo: localTodo,
        newRecord: {
          'id': 100,
          'name': 'Buy oat milk',
          'categoryId': 10,
          'todoFileId': 1,
          'notes': '2%',
          'done': false,
          'visible': true,
          'expanded': false,
          'order': 0,
          'last_updated': '2026-03-21T10:01:00.000',
        },
        deletedTodoId: null,
      );

      expect(shouldSkip, isFalse);
    });

    test('does not skip todo delete when todo exists locally', () {
      final localTodo = const Todo(
        id: 100,
        name: 'Buy milk',
        categoryId: 10,
        todoFileId: 1,
      );

      final shouldSkip = NotesSyncService.shouldSkipTodoRefresh(
        eventType: 'PostgresChangeEvent.delete',
        localTodo: localTodo,
        newRecord: null,
        deletedTodoId: 100,
      );

      expect(shouldSkip, isFalse);
    });

    test('does not skip todo delete when category is missing but local todo exists', () {
      final localTodo = const Todo(
        id: 100,
        name: 'Buy milk',
        categoryId: 10,
        todoFileId: 1,
      );

      final shouldSkip = NotesSyncService.shouldSkipTodoRefresh(
        eventType: 'PostgresChangeEvent.delete',
        localTodo: localTodo,
        newRecord: null,
        deletedTodoId: 100,
      );

      expect(shouldSkip, isFalse);
    });

    test('treats non-none connectivity results as a usable connection hint', () {
      expect(
        NotesSyncService.hasNetworkConnection(const [ConnectivityResult.wifi]),
        isTrue,
      );
      expect(
        NotesSyncService.hasNetworkConnection(
          const [ConnectivityResult.none, ConnectivityResult.mobile],
        ),
        isTrue,
      );
      expect(
        NotesSyncService.hasNetworkConnection(const [ConnectivityResult.none]),
        isFalse,
      );
    });
  });
}
