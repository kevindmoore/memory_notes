import 'package:lumberdash/lumberdash.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/data/repositories.dart';
import 'package:signals/signals.dart';

class TodoFileController {
  final TodoFileRepository _repo;

  TodoFileController(this._repo);

  final todoFiles = listSignal<TodoFile>([]);
  final isLoading = signal(false);
  final error = signal<String?>(null);

  Future<void> load() async {
    isLoading.value = true;
    error.value = null;
    try {
      final result = await _repo.getAll();
      todoFiles.value = result;
    } catch (e) {
      logError('TodoFileController.load: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<TodoFile?> create(String name) async {
    try {
      final created = await _repo.add(name);
      if (created != null) {
        todoFiles.value = [...todoFiles.value, created];
      }
      return created;
    } catch (e) {
      logError('TodoFileController.create: $e');
    }
    return null;
  }

  Future<TodoFile?> update(TodoFile file) async {
    try {
      final current = await getById(file.id);
      if (current != null && current.name == file.name) {
        return current;
      }
      final updated = await _repo.update(
        file.copyWith(lastUpdated: DateTime.now()),
      );
      if (updated != null) {
        _replaceFile(updated);
      }
      return updated;
    } catch (e) {
      logError('TodoFileController.update: $e');
    }
    return null;
  }

  Future<TodoFile?> getById(int? id) async {
    if (id == null) return null;
    final local = todoFiles.value.where((file) => file.id == id).firstOrNull;
    if (local != null) {
      return local;
    }
    final allFiles = await _repo.getAll();
    return allFiles.where((file) => file.id == id).firstOrNull;
  }

  Future<TodoFile?> touchFile(
    int fileId, {
    DateTime? timestamp,
  }) async {
    final current = await getById(fileId);
    if (current == null) return null;
    final nextTimestamp = timestamp ?? DateTime.now();
    final didTouch = await _repo.touchLastUpdated(fileId, nextTimestamp);
    if (!didTouch) return null;
    final updated = current.copyWith(lastUpdated: nextTimestamp);
    _replaceFile(updated);
    return updated;
  }

  Future<void> delete(int id) async {
    try {
      await _repo.delete(id);
      todoFiles.value = todoFiles.value.where((file) => file.id != id).toList(growable: false);
    } catch (e) {
      logError('TodoFileController.delete: $e');
    }
  }

  void _replaceFile(TodoFile updated) {
    todoFiles.value = todoFiles.value
        .map((file) => file.id == updated.id ? updated : file)
        .toList(growable: false);
  }
}
