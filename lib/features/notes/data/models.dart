import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supa_manager/supa_manager.dart';

part 'models.freezed.dart';
part 'models.g.dart';

const todoFileTableName = 'TodoFiles';
const categoryTableName = 'Categories';
const todoTableName = 'Todos';
const currentStateTableName = 'CurrentState';
const instantNoteTableName = 'InstantNotes';
const todoFileIdName = 'todoFileId';
const categoryIdName = 'categoryId';
const nameField = 'name';

// ---------------------------------------------------------------------------
// TodoFile
// ---------------------------------------------------------------------------

@Freezed(makeCollectionsUnmodifiable: false)
abstract class TodoFile with _$TodoFile {
  const factory TodoFile({
    required String name,
    @JsonKey(includeIfNull: false) int? id,
    @JsonKey(name: 'user_id', includeIfNull: false) String? userId,
    @JsonKey(name: 'last_updated', includeIfNull: false) DateTime? lastUpdated,
    @JsonKey(name: 'created_at', includeIfNull: false) DateTime? createdAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(<Category>[])
    List<Category> categories,
  }) = _TodoFile;

  factory TodoFile.fromJson(Map<String, dynamic> json) => _$TodoFileFromJson(json);
}

class TodoFileTableData extends TableData<TodoFile> {
  TodoFileTableData() {
    tableName = todoFileTableName;
  }

  @override
  TodoFile fromJson(Map<String, dynamic> json) => TodoFile.fromJson(json);
}

class TodoFileTableEntry with TableEntry<TodoFile> {
  final TodoFile todoFile;

  TodoFileTableEntry(this.todoFile);

  @override
  TodoFileTableEntry addUserId(String userId) =>
      TodoFileTableEntry(todoFile.copyWith(userId: userId));

  @override
  Map<String, dynamic> toJson() => todoFile.toJson();

  @override
  int? get id => todoFile.id;

  @override
  set id(int? id) {}
}

// ---------------------------------------------------------------------------
// Category
// ---------------------------------------------------------------------------

@Freezed(makeCollectionsUnmodifiable: false)
abstract class Category with _$Category {
  @JsonSerializable(explicitToJson: true)
  const factory Category({
    required String name,
    @JsonKey(includeIfNull: false) int? id,
    @JsonKey(includeIfNull: false) int? todoFileId,
    @JsonKey(name: 'user_id', includeIfNull: false) String? userId,
    @JsonKey(name: 'last_updated', includeIfNull: false) DateTime? lastUpdated,
    @JsonKey(name: 'created_at', includeIfNull: false) DateTime? createdAt,
    @JsonKey(includeFromJson: false, includeToJson: false) @Default(<Todo>[]) List<Todo> todos,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
}

class CategoryTableData extends TableData<Category> {
  CategoryTableData() {
    tableName = categoryTableName;
  }

  @override
  Category fromJson(Map<String, dynamic> json) => Category.fromJson(json);
}

class CategoryTableEntry with TableEntry<Category> {
  final Category category;
  final int todoFileId;

  CategoryTableEntry(this.category, this.todoFileId);

  @override
  CategoryTableEntry addUserId(String userId) =>
      CategoryTableEntry(category.copyWith(todoFileId: todoFileId, userId: userId), todoFileId);

  @override
  Map<String, dynamic> toJson() => category.toJson();

  @override
  int? get id => category.id;

  @override
  set id(int? id) {}
}

// ---------------------------------------------------------------------------
// Todo
// ---------------------------------------------------------------------------

@Freezed(makeCollectionsUnmodifiable: false)
abstract class Todo with _$Todo {
  const factory Todo({
    @Default(false) bool done,
    @Default(true) bool visible,
    @Default(false) bool expanded,
    @Default(0) int order,
    required String name,
    @JsonKey(includeIfNull: false) int? id,
    @JsonKey(name: 'user_id', includeIfNull: false) String? userId,
    @JsonKey(includeIfNull: false) int? todoFileId,
    @JsonKey(includeIfNull: false) int? categoryId,
    @JsonKey(includeIfNull: false) int? parentTodoId,
    @Default('') String notes,
    @JsonKey(name: 'last_updated', includeIfNull: false) DateTime? lastUpdated,
    @JsonKey(name: 'created_at', includeIfNull: false) DateTime? createdAt,
    @JsonKey(includeFromJson: false, includeToJson: false) @Default(<Todo>[]) List<Todo> children,
  }) = _Todo;

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}

class TodoTableData extends TableData<Todo> {
  TodoTableData() {
    tableName = todoTableName;
  }

  @override
  Todo fromJson(Map<String, dynamic> json) => Todo.fromJson(json);
}

class TodoTableEntry with TableEntry<Todo> {
  final Todo todo;
  final int todoFileId;
  final int categoryId;

  TodoTableEntry(this.todo, this.todoFileId, this.categoryId);

  @override
  TodoTableEntry addUserId(String userId) => TodoTableEntry(
    todo.copyWith(categoryId: categoryId, todoFileId: todoFileId, userId: userId),
    todoFileId,
    categoryId,
  );

  @override
  Map<String, dynamic> toJson() => todo.toJson();

  @override
  int? get id => todo.id;

  @override
  set id(int? id) {}
}

// ---------------------------------------------------------------------------
// CurrentState
// ---------------------------------------------------------------------------

@Freezed(makeCollectionsUnmodifiable: false)
abstract class CurrentState with _$CurrentState {
  const factory CurrentState({
    required String currentFiles,
    @JsonKey(includeIfNull: false) int? id,
    @JsonKey(name: 'user_id', includeIfNull: false) String? userId,
    @JsonKey(name: 'last_updated', includeIfNull: false) DateTime? lastUpdated,
  }) = _CurrentState;

  factory CurrentState.fromJson(Map<String, dynamic> json) => _$CurrentStateFromJson(json);
}

class CurrentStateTableData extends TableData<CurrentState> {
  CurrentStateTableData() {
    tableName = currentStateTableName;
  }

  @override
  CurrentState fromJson(Map<String, dynamic> json) => CurrentState.fromJson(json);
}

class CurrentStateTableEntry with TableEntry<CurrentState> {
  final CurrentState currentState;

  CurrentStateTableEntry(this.currentState);

  @override
  CurrentStateTableEntry addUserId(String userId) =>
      CurrentStateTableEntry(currentState.copyWith(userId: userId));

  @override
  Map<String, dynamic> toJson() => currentState.toJson();

  @override
  int? get id => currentState.id;

  @override
  set id(int? id) {}
}

// ---------------------------------------------------------------------------
// InstantNote
// ---------------------------------------------------------------------------

@Freezed(makeCollectionsUnmodifiable: false)
abstract class InstantNote with _$InstantNote {
  const factory InstantNote({
    required String notes,
    @JsonKey(includeIfNull: false) int? id,
    @JsonKey(name: 'user_id', includeIfNull: false) String? userId,
    @JsonKey(name: 'last_updated', includeIfNull: false) DateTime? lastUpdated,
    @JsonKey(name: 'created_at', includeIfNull: false) DateTime? createdAt,
  }) = _InstantNote;

  factory InstantNote.fromJson(Map<String, dynamic> json) => _$InstantNoteFromJson(json);
}

class InstantNoteTableData extends TableData<InstantNote> {
  InstantNoteTableData() {
    tableName = instantNoteTableName;
  }

  @override
  InstantNote fromJson(Map<String, dynamic> json) => InstantNote.fromJson(json);
}

class InstantNoteTableEntry with TableEntry<InstantNote> {
  final InstantNote instantNote;

  InstantNoteTableEntry(this.instantNote);

  @override
  InstantNoteTableEntry addUserId(String userId) =>
      InstantNoteTableEntry(instantNote.copyWith(userId: userId));

  @override
  Map<String, dynamic> toJson() => instantNote.toJson();

  @override
  int? get id => instantNote.id;

  @override
  set id(int? id) {}
}
