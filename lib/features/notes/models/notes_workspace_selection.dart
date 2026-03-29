import 'package:freezed_annotation/freezed_annotation.dart';

part 'notes_workspace_selection.freezed.dart';

@freezed
abstract class NotesWorkspaceSelection with _$NotesWorkspaceSelection {
  const factory NotesWorkspaceSelection({
    int? fileId,
    int? categoryId,
    int? todoId,
    @Default(<int>[]) List<int> todoPath,
  }) = _NotesWorkspaceSelection;
}

extension NotesWorkspaceSelectionX on NotesWorkspaceSelection {
  NotesWorkspaceSelection patch({
    int? fileId,
    int? categoryId,
    int? todoId,
    List<int>? todoPath,
    bool clearFile = false,
    bool clearCategory = false,
    bool clearTodo = false,
  }) {
    return copyWith(
      fileId: clearFile ? null : (fileId ?? this.fileId),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      todoId: clearTodo ? null : (todoId ?? this.todoId),
      todoPath: clearTodo ? const <int>[] : (todoPath ?? this.todoPath),
    );
  }
}
