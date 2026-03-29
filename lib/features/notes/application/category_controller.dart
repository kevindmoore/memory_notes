import 'package:lumberdash/lumberdash.dart';
import 'package:memory_notes/features/notes/application/todo_file_controller.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/data/repositories.dart';
import 'package:signals/signals.dart';

class CategoryController {
  CategoryController(this._categoryRepo, {TodoFileController? todoFiles}) : _todoFiles = todoFiles;

  final CategoryRepository _categoryRepo;
  final TodoFileController? _todoFiles;

  final categories = listSignal<Category>([]);
  final loadedCategoryFileIds = listSignal<int>([]);
  final isLoading = signal(false);
  final error = signal<String?>(null);

  Future<void> loadCategories(int todoFileId) async {
    isLoading.value = true;
    error.value = null;
    try {
      final result = await _categoryRepo.getByTodoFile(todoFileId);
      _storeCategoriesForFile(todoFileId, result);
      if (!loadedCategoryFileIds.contains(todoFileId)) {
        loadedCategoryFileIds.add(todoFileId);
      }
    } catch (e) {
      logError('CategoryController.loadCategories: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCategoriesForFiles(List<int> todoFileIds) async {
    isLoading.value = true;
    error.value = null;
    try {
      final results = await Future.wait(
        todoFileIds.map((id) => _categoryRepo.getByTodoFile(id)),
      );
      final merged = <int?, Category>{
        for (final category in categories.value) category.id: category,
      };
      for (var index = 0; index < todoFileIds.length; index++) {
        final fileId = todoFileIds[index];
        merged.removeWhere((_, category) => category.todoFileId == fileId);
        for (final category in results[index]) {
          merged[category.id] = category;
        }
        if (!loadedCategoryFileIds.contains(fileId)) {
          loadedCategoryFileIds.add(fileId);
        }
      }
      categories.value = merged.values.toList();
    } catch (e) {
      logError('CategoryController.loadCategoriesForFiles: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAllForSearch(List<int> fileIds) async {
    try {
      final allCategories = (await Future.wait(
        fileIds.map((id) => _categoryRepo.getByTodoFile(id)),
      ))
          .expand((list) => list)
          .toList();

      final merged = {
        for (final category in categories.value) category.id: category,
      };
      for (final category in allCategories) {
        merged[category.id] = category;
      }
      categories.value = merged.values.toList();
    } catch (e) {
      logError('CategoryController.loadAllForSearch: $e');
    }
  }

  Future<Category?> createCategory(int todoFileId, String name) async {
    try {
      final created = await _categoryRepo.add(
        Category(name: name, todoFileId: todoFileId),
        todoFileId,
      );
      if (created != null) {
        categories.value = [...categories.value, created];
        await _todoFiles?.touchFile(todoFileId);
      }
      return created;
    } catch (e) {
      logError('CategoryController.createCategory: $e');
    }
    return null;
  }

  Future<Category?> renameCategory(Category category, String name) async {
    try {
      if (category.name == name) {
        return category;
      }
      final timestamp = DateTime.now();
      final updated = await _categoryRepo.update(
        category.copyWith(name: name, lastUpdated: timestamp),
        category.todoFileId!,
      );
      if (updated != null) {
        _replaceCategory(updated);
        await _todoFiles?.touchFile(category.todoFileId!, timestamp: timestamp);
      }
      return updated;
    } catch (e) {
      logError('CategoryController.renameCategory: $e');
    }
    return null;
  }

  Future<void> deleteCategory(int categoryId) async {
    try {
      final category = categories.value.where((item) => item.id == categoryId).firstOrNull;
      await _categoryRepo.delete(categoryId);
      categories.value = categories.value
          .where((category) => category.id != categoryId)
          .toList(growable: false);
      if (category?.todoFileId != null) {
        await _todoFiles?.touchFile(category!.todoFileId!);
      }
    } catch (e) {
      logError('CategoryController.deleteCategory: $e');
    }
  }

  Future<Category?> getById({
    required int categoryId,
    required int todoFileId,
  }) async {
    final local = categories.value.where((item) => item.id == categoryId).firstOrNull;
    if (local != null) {
      return local;
    }
    final fileCategories = await _categoryRepo.getByTodoFile(todoFileId);
    return fileCategories.where((item) => item.id == categoryId).firstOrNull;
  }

  Future<Category?> touchCategory({
    required int categoryId,
    required int todoFileId,
    DateTime? timestamp,
  }) async {
    final current = await getById(categoryId: categoryId, todoFileId: todoFileId);
    if (current == null) return null;
    final nextTimestamp = timestamp ?? DateTime.now();
    final didTouch = await _categoryRepo.touchLastUpdated(categoryId, nextTimestamp);
    if (!didTouch) return null;
    final updated = current.copyWith(lastUpdated: nextTimestamp);
    _replaceCategory(updated);
    return updated;
  }

  void _replaceCategory(Category updated) {
    categories.value = categories.value
        .map((category) => category.id == updated.id ? updated : category)
        .toList(growable: false);
  }

  void _storeCategoriesForFile(int todoFileId, List<Category> nextCategories) {
    final merged = <int?, Category>{};
    for (final category in categories.value) {
      if (category.todoFileId != todoFileId) {
        merged[category.id] = category;
      }
    }
    for (final category in nextCategories) {
      merged[category.id] = category;
    }
    categories.value = merged.values.toList();
  }
}
