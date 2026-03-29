import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memory_notes/features/notes/data/models.dart';

part 'mobile_note_edit_view_state.freezed.dart';

@freezed
abstract class MobileNoteEditViewState with _$MobileNoteEditViewState {
  const factory MobileNoteEditViewState({
    required String fileName,
    Category? category,
    Todo? parentTodo,
    Todo? focusedTodo,
    required String screenTitle,
    @Default(<Todo>[]) List<Todo> allTodos,
    @Default(<Todo>[]) List<Todo> visibleTodos,
  }) = _MobileNoteEditViewState;
}
