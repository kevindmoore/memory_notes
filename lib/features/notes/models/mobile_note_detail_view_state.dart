import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memory_notes/features/notes/data/models.dart';

part 'mobile_note_detail_view_state.freezed.dart';

@freezed
abstract class MobileNoteDetailViewState with _$MobileNoteDetailViewState {
  const factory MobileNoteDetailViewState({
    required String fileName,
    @Default(<MobileNoteDetailCategoryItem>[]) List<MobileNoteDetailCategoryItem> categories,
    @Default(false) bool isLoading,
  }) = _MobileNoteDetailViewState;
}

@freezed
abstract class MobileNoteDetailCategoryItem with _$MobileNoteDetailCategoryItem {
  const factory MobileNoteDetailCategoryItem({
    required Category category,
    @Default(0) int topLevelTodoCount,
  }) = _MobileNoteDetailCategoryItem;
}
