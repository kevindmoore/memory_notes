import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memory_notes/features/notes/data/models.dart';

part 'notes_workspace_view_state.freezed.dart';

@freezed
abstract class NotesWorkspaceViewState with _$NotesWorkspaceViewState {
  const factory NotesWorkspaceViewState({
    @Default(<TodoFile>[]) List<TodoFile> files,
    @Default(<DesktopWorkspaceFileItem>[]) List<DesktopWorkspaceFileItem> fileItems,
    @Default(<DesktopWorkspaceFileItem>[]) List<DesktopWorkspaceFileItem> openFileItems,
    @Default(<DesktopWorkspaceFileItem>[]) List<DesktopWorkspaceFileItem> availableFileItems,
    @Default(<int>[]) List<int> openFileIds,
    TodoFile? selectedFile,
    Category? selectedCategory,
    @Default(<Category>[]) List<Category> categories,
    @Default(<Todo>[]) List<Todo> todos,
    Todo? selectedTodo,
    @Default(<int>[]) List<int> selectedTodoPath,
  }) = _NotesWorkspaceViewState;
}

@freezed
abstract class DesktopWorkspaceFileItem with _$DesktopWorkspaceFileItem {
  const factory DesktopWorkspaceFileItem({
    required TodoFile file,
    @Default(0) int categoryCount,
    @Default(false) bool isSelected,
    @Default(false) bool isOpen,
  }) = _DesktopWorkspaceFileItem;
}
