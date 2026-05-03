import 'package:memory_notes/features/notes/application/category_controller.dart';
import 'package:memory_notes/features/notes/application/notes_query_service.dart';
import 'package:memory_notes/features/notes/application/todo_controller.dart';
import 'package:memory_notes/features/notes/application/todo_file_controller.dart';
import 'package:memory_notes/features/notes/data/models.dart';

class ListMergeResult {
  const ListMergeResult({
    this.primaryFile,
    this.mergedListCount = 0,
    this.mergedCategoryCount = 0,
  });

  final TodoFile? primaryFile;
  final int mergedListCount;
  final int mergedCategoryCount;

  bool get didMerge => mergedListCount > 0;
}

class NotesMergeService {
  NotesMergeService({
    required this.todoFiles,
    required this.categories,
    required this.todos,
    required this.query,
  });

  final TodoFileController todoFiles;
  final CategoryController categories;
  final TodoController todos;
  final NotesQueryService query;

  Future<ListMergeResult> mergeDuplicateLists({
    int? preferredFileId,
  }) async {
    await todoFiles.load();
    final files =
        todoFiles.todoFiles.value.where((file) => file.id != null).toList(growable: false);
    final groups = <String, List<TodoFile>>{};
    for (final file in files) {
      groups.putIfAbsent(query.normalizeName(file.name), () => <TodoFile>[]).add(file);
    }

    TodoFile? primaryFile;
    var mergedListCount = 0;
    var mergedCategoryCount = 0;

    for (final duplicates in groups.values) {
      if (duplicates.length < 2) continue;
      final primary = _selectPrimaryFile(duplicates, preferredFileId: preferredFileId);
      primaryFile ??= primary;
      for (final duplicate in duplicates) {
        if (duplicate.id == primary.id) continue;
        final mergedCategories = await _mergeFileIntoPrimary(source: duplicate, target: primary);
        mergedListCount += 1;
        mergedCategoryCount += mergedCategories;
      }
    }

    return ListMergeResult(
      primaryFile: primaryFile,
      mergedListCount: mergedListCount,
      mergedCategoryCount: mergedCategoryCount,
    );
  }

  TodoFile _selectPrimaryFile(
    List<TodoFile> files, {
    int? preferredFileId,
  }) {
    if (preferredFileId != null) {
      final preferred = files.where((file) => file.id == preferredFileId).firstOrNull;
      if (preferred != null) {
        return preferred;
      }
    }

    final sorted = List<TodoFile>.from(files)
      ..sort((a, b) {
        final updatedComparison =
            (a.lastUpdated ?? DateTime(0)).compareTo(b.lastUpdated ?? DateTime(0));
        if (updatedComparison != 0) {
          return updatedComparison;
        }
        return (a.id ?? 0).compareTo(b.id ?? 0);
      });
    return sorted.first;
  }

  Future<int> _mergeFileIntoPrimary({
    required TodoFile source,
    required TodoFile target,
  }) async {
    final sourceId = source.id;
    final targetId = target.id;
    if (sourceId == null || targetId == null) return 0;

    await categories.loadCategories(sourceId);
    await categories.loadCategories(targetId);

    final sourceCategories = query.categoriesForFile(categories.categories.value, sourceId);
    var mergedCategoryCount = 0;

    for (final sourceCategory in sourceCategories) {
      final targetCategory = categories.findByName(targetId, sourceCategory.name);
      if (targetCategory == null) {
        final moved = await categories.moveCategoryToFile(
          category: sourceCategory,
          targetFileId: targetId,
        );
        if (moved != null) {
          mergedCategoryCount += 1;
        }
        continue;
      }

      final didMergeCategory = await _mergeCategoryIntoTarget(
        sourceCategory: sourceCategory,
        targetCategory: targetCategory,
        targetFileId: targetId,
      );
      if (didMergeCategory) {
        mergedCategoryCount += 1;
      }
    }

    await todoFiles.delete(sourceId);
    return mergedCategoryCount;
  }

  Future<bool> _mergeCategoryIntoTarget({
    required Category sourceCategory,
    required Category targetCategory,
    required int targetFileId,
  }) async {
    final sourceCategoryId = sourceCategory.id;
    final targetCategoryId = targetCategory.id;
    if (sourceCategoryId == null || targetCategoryId == null) return false;

    await todos.loadTodos(sourceCategoryId);
    await todos.loadTodos(targetCategoryId);
    final sourceTodos = List<Todo>.from(
      query.todosForCategory(todos.todosByCategory.value, sourceCategoryId),
    );

    for (final todo in sourceTodos) {
      await todos.moveTodoToCategory(
        todo: todo,
        targetFileId: targetFileId,
        targetCategoryId: targetCategoryId,
      );
    }

    await categories.deleteCategory(sourceCategoryId);
    return true;
  }
}
