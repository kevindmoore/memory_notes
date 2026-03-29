import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memory_notes/features/notes/data/models.dart';

part 'search_result_item.freezed.dart';

@freezed
sealed class SearchResultItem with _$SearchResultItem {
  const factory SearchResultItem.file({
    required TodoFile file,
  }) = SearchFileResultItem;

  const factory SearchResultItem.category({
    required Category category,
    required TodoFile parentFile,
    required String subtitle,
  }) = SearchCategoryResultItem;

  const factory SearchResultItem.todo({
    required Todo todo,
    required List<int> ancestorTodoIds,
    required Category parentCategory,
    required TodoFile parentFile,
    required String subtitle,
  }) = SearchTodoResultItem;
}
