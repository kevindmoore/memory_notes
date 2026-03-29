import 'package:memory_notes/features/notes/application/notes_mobile_store.dart';
import 'package:memory_notes/features/notes/application/notes_duplication_service.dart';
import 'package:memory_notes/features/notes/application/notes_workspace_store.dart';
import 'package:memory_notes/features/notes/application/todo_file_controller.dart';
import 'package:memory_notes/features/notes/data/models.dart';

class NotesListActions {
  const NotesListActions({
    required this.notesWorkspace,
    required this.duplication,
  });

  final NotesWorkspaceStore notesWorkspace;
  final NotesDuplicationService duplication;

  Future<TodoFile?> createList(
    String name,
  ) {
    return notesWorkspace.createList(name);
  }

  Future<void> openFile(TodoFile file) {
    return notesWorkspace.selectFile(file);
  }

  Future<void> closeFile(TodoFile file) {
    return notesWorkspace.closeFile(file);
  }

  Future<void> reloadList(TodoFile file) {
    return notesWorkspace.reloadFile(file.id!);
  }

  Future<void> reloadAll() {
    return notesWorkspace.reloadOpenFiles();
  }

  Future<Category?> createCategory(
    TodoFile file,
    String name,
  ) {
    return notesWorkspace.createCategory(file, name);
  }

  Future<void> addNote(
    Category category,
    String text,
  ) {
    return notesWorkspace.createQuickNote(category, text);
  }

  Future<void> renameList(
    TodoFile file,
    String name,
  ) {
    return notesWorkspace.renameList(file, name);
  }

  Future<void> renameTodo(
    Todo todo,
    String name,
  ) {
    return notesWorkspace.renameTodo(todo, name);
  }

  Future<void> renameCategory(
    Category category,
    String name,
  ) {
    return notesWorkspace.renameCategory(category, name);
  }

  Future<void> deleteCategory({
    required Category category,
    required TodoFile file,
  }) {
    return notesWorkspace.deleteCategory(category: category, file: file);
  }

  Future<void> saveTodoNotes({
    required Todo todo,
    required String notes,
  }) {
    return notesWorkspace.saveTodoNotes(todo, notes);
  }

  Future<TodoFile?> duplicateList({
    required TodoFile file,
    required String name,
  }) {
    return duplication.duplicateList(file, name: name);
  }

  Future<Category?> duplicateCategory({
    required Category category,
    required String name,
  }) {
    return duplication.duplicateCategory(category, name: name);
  }

  Future<Todo?> duplicateTodo({
    required Todo todo,
    required String name,
  }) {
    return duplication.duplicateTodo(todo, name: name);
  }
}

class NoteDetailActions {
  const NoteDetailActions({
    required this.todoFiles,
    required this.notesMobile,
    required this.duplication,
  });

  final TodoFileController todoFiles;
  final NotesMobileStore notesMobile;
  final NotesDuplicationService duplication;

  Future<Category?> createCategory({
    required int fileId,
    required String name,
  }) {
    return notesMobile.createCategory(fileId: fileId, name: name);
  }

  TodoFile? findFileById(int fileId) {
    return todoFiles.todoFiles.value.where((item) => item.id == fileId).firstOrNull;
  }

  Future<TodoFile?> duplicateList(
    TodoFile file, {
    required String name,
  }) {
    return duplication.duplicateList(file, name: name);
  }

  Future<Category?> duplicateCategory({
    required Category category,
    required String name,
  }) {
    return duplication.duplicateCategory(category, name: name);
  }

  Future<void> reloadList({
    required int fileId,
  }) {
    return notesMobile.loadFile(fileId);
  }

  Future<void> deleteList({
    required int fileId,
  }) {
    return notesMobile.deleteList(fileId);
  }

  Future<void> renameList({
    required TodoFile file,
    required String name,
  }) {
    return notesMobile.renameList(file, name);
  }

  Future<void> renameCategory({
    required Category category,
    required String name,
  }) {
    return notesMobile.renameCategory(category, name);
  }

  Future<void> deleteCategory({
    required int categoryId,
  }) {
    return notesMobile.deleteCategory(categoryId);
  }
}

class NoteEditActions {
  const NoteEditActions({
    required this.notesMobile,
    required this.duplication,
  });

  final NotesMobileStore notesMobile;
  final NotesDuplicationService duplication;

  Future<void> addNote({
    required int fileId,
    required int categoryId,
    required String notes,
    int? parentTodoId,
  }) {
    return notesMobile.addNote(
      fileId: fileId,
      categoryId: categoryId,
      notes: notes,
      parentTodoId: parentTodoId,
    );
  }

  Future<void> addSubtask({
    required int fileId,
    required int categoryId,
    required int parentTodoId,
    required String name,
  }) {
    return notesMobile.addTodo(
      fileId: fileId,
      categoryId: categoryId,
      name: name,
      parentTodoId: parentTodoId,
    );
  }

  Future<void> saveTodoNotes({
    required Todo todo,
    required String notes,
  }) {
    return notesMobile.saveTodoNotes(todo, notes);
  }

  Future<void> renameCategory({
    required Category category,
    required String name,
  }) {
    return notesMobile.renameCategory(category, name);
  }

  Future<void> renameTodo({
    required Todo todo,
    required String name,
  }) {
    return notesMobile.renameTodo(todo, name);
  }

  Future<void> deleteTodo({
    required Todo todo,
  }) {
    return notesMobile.deleteTodo(todo);
  }

  Future<Category?> duplicateCategory({
    required Category category,
    required String name,
  }) {
    return duplication.duplicateCategory(category, name: name);
  }

  Future<Todo?> duplicateTodo({
    required Todo todo,
    required String name,
  }) {
    return duplication.duplicateTodo(todo, name: name);
  }

  Future<void> deleteCategory({
    required int categoryId,
  }) {
    return notesMobile.deleteCategory(categoryId);
  }
}
