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

  Future<void> preload({List<int>? openFileIds}) async {
    isLoading.value = true;
    try {
      await todoFiles.load();
      final normalizedOpenFileIds = openFileIds == null
          ? null
          : query.normalizeFileIds(openFileIds, todoFiles.todoFiles.value);
      final fileIds = normalizedOpenFileIds ??
          todoFiles.todoFiles.value
              .where((file) => file.id != null)
              .map((file) => file.id!)
              .toList();
      await categories.loadAllForSearch(fileIds);
      final fileIdSet = fileIds.toSet();
      final categoryIds = categories.categories.value
          .where(
            (category) =>
                category.id != null &&
                category.todoFileId != null &&
                fileIdSet.contains(category.todoFileId),
          )
          .map((category) => category.id!)
          .toList();
      await Future.wait(categoryIds.map(todos.loadTodos));
    } finally {
      isLoading.value = false;
    }
  }

  // Returns 0 (no match), 1 (substring), 2 (word-start), or 3 (whole word).
  static int _scoreWord(String lowerText, String word) {
    if (!lowerText.contains(word)) return 0;
    final escaped = RegExp.escape(word);
    if (RegExp('\\b$escaped\\b').hasMatch(lowerText)) return 3;
    if (RegExp('\\b$escaped').hasMatch(lowerText)) return 2;
    return 1;
  }

  // Scores text against all words. Returns null if any word is missing.
  static int? _scoreText(String text, List<String> words) {
    final lower = text.toLowerCase();
    var total = 0;
    for (final word in words) {
      final s = _scoreWord(lower, word);
      if (s == 0) return null;
      total += s;
    }
    return total;
  }

  // Extracts a short snippet from [text] centred on the first matching word.
  static String? _extractSnippet(String text, List<String> words) {
    final lower = text.toLowerCase();
    for (final word in words) {
      final idx = lower.indexOf(word);
      if (idx == -1) continue;
      final start = (idx - 20).clamp(0, text.length);
      final end = (idx + 70).clamp(0, text.length);
      var snippet = text.substring(start, end).replaceAll('\n', ' ').trim();
      if (start > 0) snippet = '…$snippet';
      if (end < text.length) snippet = '$snippet…';
      return snippet;
    }
    return null;
  }

  List<SearchResultItem> buildResults(
    String searchText, {
    List<int>? openFileIds,
  }) {
    final normalizedQuery = searchText.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return const [];

    final words = normalizedQuery
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    final scored = <(int, SearchResultItem)>[];
    final allFiles = todoFiles.todoFiles.value;
    final openFileIdSet = openFileIds?.toSet();
    final files = openFileIdSet == null
        ? allFiles
        : allFiles.where((file) => file.id != null && openFileIdSet.contains(file.id!)).toList();
    final allCategories = categories.categories.value;
    final todosMap = todos.todosByCategory;

    for (final file in files) {
      final fileScore = _scoreText(file.name, words);
      if (fileScore != null) {
        scored.add((fileScore, SearchResultItem.file(file: file)));
      }

      final categoriesForFile = query.categoriesForFile(allCategories, file.id);
      for (final category in categoriesForFile) {
        final catScore = _scoreText(category.name, words);
        if (catScore != null) {
          scored.add((
            catScore,
            SearchResultItem.category(
              category: category,
              parentFile: file,
              subtitle: 'Category in ${file.name}',
            ),
          ));
        }

        final categoryTodos = query.todosForCategory(todosMap.value, category.id);
        for (final todo in categoryTodos) {
          // Each word must appear in name OR notes (combined match).
          final combinedText = '${todo.name} ${todo.notes}'.toLowerCase();
          if (words.any((w) => !combinedText.contains(w))) continue;

          // Name matches weighted 2×, notes matches 1×.
          var totalScore = 0;
          var nameMatched = false;
          for (final word in words) {
            final ns = _scoreWord(todo.name.toLowerCase(), word);
            final ms = todo.notes.isNotEmpty
                ? _scoreWord(todo.notes.toLowerCase(), word)
                : 0;
            if (ns > 0) {
              totalScore += ns * 2;
              nameMatched = true;
            } else {
              totalScore += ms;
            }
          }

          final todoCategory =
              query.findCategoryById(allCategories, todo.categoryId) ?? category;
          final todoFile =
              query.findFileById(allFiles, todo.todoFileId) ?? file;
          final ancestorTodoIds =
              query.buildAncestorTodoIds(todo, categoryTodos);
          final breadcrumb = query.buildTodoBreadcrumb(
            todo: todo,
            allTodos: categoryTodos,
            category: todoCategory,
            file: todoFile,
          );

          // Append a notes snippet when the match came from notes only.
          var subtitle = breadcrumb;
          if (!nameMatched && todo.notes.isNotEmpty) {
            final snippet = _extractSnippet(todo.notes, words);
            if (snippet != null) subtitle = '$breadcrumb\n$snippet';
          }

          scored.add((
            totalScore,
            SearchResultItem.todo(
              todo: todo,
              ancestorTodoIds: ancestorTodoIds,
              parentCategory: todoCategory,
              parentFile: todoFile,
              subtitle: subtitle,
            ),
          ));
        }
      }
    }

    scored.sort((a, b) => b.$1.compareTo(a.$1));
    return scored.map((e) => e.$2).toList();
  }
}
