import 'package:lumberdash/lumberdash.dart';
import 'package:memory_notes/features/notes/application/todo_controller.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/data/repositories.dart';
import 'package:signals/signals.dart';

class InstantNotesStore {
  InstantNotesStore(this._repository, this._todos);

  final InstantNoteRepository _repository;
  final TodoController _todos;

  final instantNotes = listSignal<InstantNote>([]);
  final isLoading = signal(false);
  final isSaving = signal(false);
  final error = signal<String?>(null);

  Future<void> load() async {
    isLoading.value = true;
    error.value = null;
    try {
      instantNotes.value = await _repository.getAll();
    } catch (e) {
      logError('InstantNotesStore.load: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<InstantNote?> create(String notes) async {
    final trimmedNotes = notes.trim();
    if (trimmedNotes.isEmpty) {
      return null;
    }

    isSaving.value = true;
    error.value = null;
    try {
      final created = await _repository.add(trimmedNotes);
      if (created != null) {
        instantNotes.value = [created, ...instantNotes.value];
      }
      return created;
    } catch (e) {
      logError('InstantNotesStore.create: $e');
      error.value = e.toString();
    } finally {
      isSaving.value = false;
    }
    return null;
  }

  Future<bool> moveToTodo({
    required InstantNote instantNote,
    required int fileId,
    required int categoryId,
    required String todoName,
  }) async {
    final noteId = instantNote.id;
    final trimmedName = todoName.trim();
    if (noteId == null || trimmedName.isEmpty) {
      return false;
    }

    isSaving.value = true;
    error.value = null;
    try {
      final createdTodo = await _todos.addTodo(
        fileId,
        categoryId,
        trimmedName,
        notes: instantNote.notes,
      );
      if (createdTodo == null) {
        error.value = 'Could not create todo.';
        return false;
      }

      await _repository.delete(noteId);
      instantNotes.value = instantNotes.value
          .where((note) => note.id != noteId)
          .toList(growable: false);
      return true;
    } catch (e) {
      logError('InstantNotesStore.moveToTodo: $e');
      error.value = e.toString();
    } finally {
      isSaving.value = false;
    }
    return false;
  }

  Future<InstantNote?> update(InstantNote instantNote, String notes) async {
    final noteId = instantNote.id;
    final trimmedNotes = notes.trim();
    if (noteId == null || trimmedNotes.isEmpty) {
      return null;
    }
    if (trimmedNotes == instantNote.notes) {
      return instantNote;
    }

    isSaving.value = true;
    error.value = null;
    try {
      final updated = await _repository.update(
        instantNote.copyWith(notes: trimmedNotes, lastUpdated: DateTime.now()),
      );
      if (updated != null) {
        instantNotes.value = instantNotes.value
            .map((note) => note.id == noteId ? updated : note)
            .toList(growable: false);
      }
      return updated;
    } catch (e) {
      logError('InstantNotesStore.update: $e');
      error.value = e.toString();
    } finally {
      isSaving.value = false;
    }
    return null;
  }

  Future<void> delete(InstantNote instantNote) async {
    final noteId = instantNote.id;
    if (noteId == null) return;

    isSaving.value = true;
    error.value = null;
    try {
      await _repository.delete(noteId);
      instantNotes.value = instantNotes.value
          .where((note) => note.id != noteId)
          .toList(growable: false);
    } catch (e) {
      logError('InstantNotesStore.delete: $e');
      error.value = e.toString();
    } finally {
      isSaving.value = false;
    }
  }
}
