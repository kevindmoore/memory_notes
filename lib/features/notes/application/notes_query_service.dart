import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/models/category_sort_order.dart';
import 'package:memory_notes/features/notes/models/notes_sort_order.dart';
import 'package:memory_notes/features/notes/models/todo_sort_order.dart';

class NotesQueryService {
  const NotesQueryService();

  TodoFile? findFileById(Iterable<TodoFile> files, int? fileId) {
    if (fileId == null) return null;
    return files.where((file) => file.id == fileId).firstOrNull;
  }

  Category? findCategoryById(Iterable<Category> categories, int? categoryId) {
    if (categoryId == null) return null;
    return categories.where((category) => category.id == categoryId).firstOrNull;
  }

  Todo? findTodoById(Iterable<Todo> todos, int? todoId) {
    if (todoId == null) return null;
    return todos.where((todo) => todo.id == todoId).firstOrNull;
  }

  List<int> normalizeFileIds(Iterable<int> fileIds, Iterable<TodoFile> files) {
    final validIds = files.where((file) => file.id != null).map((file) => file.id!).toSet();
    final normalized = <int>[];
    for (final fileId in fileIds) {
      if (validIds.contains(fileId) && !normalized.contains(fileId)) {
        normalized.add(fileId);
      }
    }
    return normalized;
  }

  List<TodoFile> sortFiles(
    Iterable<TodoFile> files, {
    required NotesSortOrder sortOrder,
    List<int> preferredFileOrder = const <int>[],
  }) {
    final list = files.toList(growable: false);
    final sorted = List<TodoFile>.from(list);
    if (preferredFileOrder.isNotEmpty) {
      final rankById = <int, int>{
        for (var index = 0; index < preferredFileOrder.length; index++)
          preferredFileOrder[index]: index,
      };
      sorted.sort((a, b) {
        final aRank = a.id == null ? null : rankById[a.id!];
        final bRank = b.id == null ? null : rankById[b.id!];
        if (aRank != null && bRank != null) {
          return aRank.compareTo(bRank);
        }
        if (aRank != null) return -1;
        if (bRank != null) return 1;
        return _compareFiles(a, b, sortOrder);
      });
      return sorted;
    }

    sorted.sort((a, b) => _compareFiles(a, b, sortOrder));
    return sorted;
  }

  List<Category> sortCategories(
    Iterable<Category> categories, {
    required CategorySortOrder sortOrder,
    Map<int, List<Todo>> todosByCategory = const <int, List<Todo>>{},
  }) {
    final sorted = categories.toList(growable: false);
    sorted.sort((a, b) {
      switch (sortOrder) {
        case CategorySortOrder.nameAZ:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case CategorySortOrder.nameZA:
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        case CategorySortOrder.newest:
          return (b.lastUpdated ?? b.createdAt ?? DateTime(0))
              .compareTo(a.lastUpdated ?? a.createdAt ?? DateTime(0));
        case CategorySortOrder.todoCount:
          final countComparison = topLevelTodoCount(
            todosByCategory,
            b.id,
          ).compareTo(topLevelTodoCount(todosByCategory, a.id));
          if (countComparison != 0) return countComparison;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
    });
    return sorted;
  }

  List<Category> categoriesForFile(Iterable<Category> categories, int? fileId) {
    if (fileId == null) return const <Category>[];
    return categories.where((category) => category.todoFileId == fileId).toList(growable: false);
  }

  List<Todo> todosForCategory(Map<int, List<Todo>> todosByCategory, int? categoryId) {
    if (categoryId == null) return const <Todo>[];
    return todosByCategory[categoryId] ?? const <Todo>[];
  }

  List<Todo> sortTodos(
    Iterable<Todo> todos, {
    required TodoSortOrder sortOrder,
  }) {
    final sorted = todos.toList(growable: false);
    sorted.sort((a, b) {
      switch (sortOrder) {
        case TodoSortOrder.nameAZ:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case TodoSortOrder.nameZA:
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        case TodoSortOrder.newest:
          return (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0));
      }
    });
    return sorted;
  }

  int topLevelTodoCount(Map<int, List<Todo>> todosByCategory, int? categoryId) {
    final todos = todosForCategory(todosByCategory, categoryId);
    return todos.where((todo) => todo.parentTodoId == null).length;
  }

  int todoCount(Map<int, List<Todo>> todosByCategory, int? categoryId) {
    return todosForCategory(todosByCategory, categoryId).length;
  }

  List<int> buildAncestorTodoIds(Todo todo, Iterable<Todo> allTodos) {
    final todoById = <int, Todo>{
      for (final current in allTodos)
        if (current.id != null) current.id!: current,
    };
    final ancestors = <int>[];
    var currentParentId = todo.parentTodoId;
    while (currentParentId != null) {
      ancestors.insert(0, currentParentId);
      currentParentId = todoById[currentParentId]?.parentTodoId;
    }
    return ancestors;
  }

  String buildTodoBreadcrumb({
    required Todo todo,
    required Iterable<Todo> allTodos,
    required Category category,
    required TodoFile file,
  }) {
    final todoById = <int, Todo>{
      for (final current in allTodos)
        if (current.id != null) current.id!: current,
    };
    final ancestorNames = buildAncestorTodoIds(todo, allTodos)
        .map((id) => todoById[id]?.name)
        .whereType<String>()
        .toList(growable: false);
    if (ancestorNames.isEmpty) {
      return '${category.name} · ${file.name}';
    }
    return '${ancestorNames.join(' > ')} > ${category.name} · ${file.name}';
  }

  int _compareFiles(TodoFile a, TodoFile b, NotesSortOrder sortOrder) {
    switch (sortOrder) {
      case NotesSortOrder.nameAZ:
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      case NotesSortOrder.nameZA:
        return b.name.toLowerCase().compareTo(a.name.toLowerCase());
      case NotesSortOrder.newest:
        return (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0));
      case NotesSortOrder.oldest:
        return (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0));
      case NotesSortOrder.lastUpdated:
        return (b.lastUpdated ?? b.createdAt ?? DateTime(0))
            .compareTo(a.lastUpdated ?? a.createdAt ?? DateTime(0));
    }
  }
}
