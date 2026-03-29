import 'package:signals/signals.dart';
import 'package:memory_notes/features/notes/application/category_controller.dart';
import 'package:memory_notes/features/notes/application/notes_query_service.dart';
import 'package:memory_notes/features/notes/application/todo_controller.dart';
import 'package:memory_notes/features/notes/application/todo_file_controller.dart';
import 'package:memory_notes/features/search/models/search_result_item.dart';

class SearchStore {
  SearchStore({
    required this.todoFiles,
    required this.categories,
    required this.todos,
    required this.query,
  });

  final TodoFileController todoFiles;
  final CategoryController categories;
  final TodoController todos;
  final NotesQueryService query;

  final isLoading = signal(false);

  Future<void> preload() async {
    isLoading.value = true;
    try {
      await todoFiles.load();
      final fileIds = todoFiles.todoFiles.value
          .where((file) => file.id != null)
          .map((file) => file.id!)
          .toList();
      await categories.loadAllForSearch(fileIds);
      await Future.wait(
        categories.categories.value
            .where((category) => category.id != null)
            .map((category) => todos.loadTodos(category.id!)),
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<SearchResultItem> buildResults(String searchText) {
    final normalizedQuery = searchText.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return const [];

    final results = <SearchResultItem>[];
    final files = todoFiles.todoFiles.value;
    final allCategories = categories.categories.value;
    final todosMap = todos.todosByCategory;

    for (final file in files) {
      if (file.name.toLowerCase().contains(normalizedQuery)) {
        results.add(SearchResultItem.file(file: file));
      }

      final categoriesForFile = query.categoriesForFile(allCategories, file.id);
      for (final category in categoriesForFile) {
        if (category.name.toLowerCase().contains(normalizedQuery)) {
          results.add(
            SearchResultItem.category(
              category: category,
              parentFile: file,
              subtitle: 'Category in ${file.name}',
            ),
          );
        }

        final categoryTodos = query.todosForCategory(todosMap.value, category.id);

        for (final todo in categoryTodos) {
          final nameMatch = todo.name.toLowerCase().contains(normalizedQuery);
          final notesMatch =
              todo.notes.isNotEmpty && todo.notes.toLowerCase().contains(normalizedQuery);
          if (!nameMatch && !notesMatch) {
            continue;
          }

          final todoCategory = query.findCategoryById(allCategories, todo.categoryId) ?? category;
          final todoFile = query.findFileById(files, todo.todoFileId) ?? file;
          final ancestorTodoIds = query.buildAncestorTodoIds(todo, categoryTodos);
          results.add(
            SearchResultItem.todo(
              todo: todo,
              ancestorTodoIds: ancestorTodoIds,
              parentCategory: todoCategory,
              parentFile: todoFile,
              subtitle: query.buildTodoBreadcrumb(
                todo: todo,
                allTodos: categoryTodos,
                category: todoCategory,
                file: todoFile,
              ),
            ),
          );
        }
      }
    }

    return results;
  }
}
