// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notes_workspace_view_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotesWorkspaceViewState {
  List<TodoFile> get files;
  List<DesktopWorkspaceFileItem> get fileItems;
  List<DesktopWorkspaceFileItem> get openFileItems;
  List<int> get openFileIds;
  TodoFile? get selectedFile;
  Category? get selectedCategory;
  List<Category> get categories;
  List<Todo> get todos;
  Todo? get selectedTodo;
  List<int> get selectedTodoPath;

  /// Create a copy of NotesWorkspaceViewState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NotesWorkspaceViewStateCopyWith<NotesWorkspaceViewState> get copyWith =>
      _$NotesWorkspaceViewStateCopyWithImpl<NotesWorkspaceViewState>(
          this as NotesWorkspaceViewState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NotesWorkspaceViewState &&
            const DeepCollectionEquality().equals(other.files, files) &&
            const DeepCollectionEquality().equals(other.fileItems, fileItems) &&
            const DeepCollectionEquality()
                .equals(other.openFileItems, openFileItems) &&
            const DeepCollectionEquality()
                .equals(other.openFileIds, openFileIds) &&
            (identical(other.selectedFile, selectedFile) ||
                other.selectedFile == selectedFile) &&
            (identical(other.selectedCategory, selectedCategory) ||
                other.selectedCategory == selectedCategory) &&
            const DeepCollectionEquality()
                .equals(other.categories, categories) &&
            const DeepCollectionEquality().equals(other.todos, todos) &&
            (identical(other.selectedTodo, selectedTodo) ||
                other.selectedTodo == selectedTodo) &&
            const DeepCollectionEquality()
                .equals(other.selectedTodoPath, selectedTodoPath));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(files),
      const DeepCollectionEquality().hash(fileItems),
      const DeepCollectionEquality().hash(openFileItems),
      const DeepCollectionEquality().hash(openFileIds),
      selectedFile,
      selectedCategory,
      const DeepCollectionEquality().hash(categories),
      const DeepCollectionEquality().hash(todos),
      selectedTodo,
      const DeepCollectionEquality().hash(selectedTodoPath));

  @override
  String toString() {
    return 'NotesWorkspaceViewState(files: $files, fileItems: $fileItems, openFileItems: $openFileItems, openFileIds: $openFileIds, selectedFile: $selectedFile, selectedCategory: $selectedCategory, categories: $categories, todos: $todos, selectedTodo: $selectedTodo, selectedTodoPath: $selectedTodoPath)';
  }
}

/// @nodoc
abstract mixin class $NotesWorkspaceViewStateCopyWith<$Res> {
  factory $NotesWorkspaceViewStateCopyWith(NotesWorkspaceViewState value,
          $Res Function(NotesWorkspaceViewState) _then) =
      _$NotesWorkspaceViewStateCopyWithImpl;
  @useResult
  $Res call(
      {List<TodoFile> files,
      List<DesktopWorkspaceFileItem> fileItems,
      List<DesktopWorkspaceFileItem> openFileItems,
      List<int> openFileIds,
      TodoFile? selectedFile,
      Category? selectedCategory,
      List<Category> categories,
      List<Todo> todos,
      Todo? selectedTodo,
      List<int> selectedTodoPath});

  $TodoFileCopyWith<$Res>? get selectedFile;
  $CategoryCopyWith<$Res>? get selectedCategory;
  $TodoCopyWith<$Res>? get selectedTodo;
}

/// @nodoc
class _$NotesWorkspaceViewStateCopyWithImpl<$Res>
    implements $NotesWorkspaceViewStateCopyWith<$Res> {
  _$NotesWorkspaceViewStateCopyWithImpl(this._self, this._then);

  final NotesWorkspaceViewState _self;
  final $Res Function(NotesWorkspaceViewState) _then;

  /// Create a copy of NotesWorkspaceViewState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? files = null,
    Object? fileItems = null,
    Object? openFileItems = null,
    Object? openFileIds = null,
    Object? selectedFile = freezed,
    Object? selectedCategory = freezed,
    Object? categories = null,
    Object? todos = null,
    Object? selectedTodo = freezed,
    Object? selectedTodoPath = null,
  }) {
    return _then(_self.copyWith(
      files: null == files
          ? _self.files
          : files // ignore: cast_nullable_to_non_nullable
              as List<TodoFile>,
      fileItems: null == fileItems
          ? _self.fileItems
          : fileItems // ignore: cast_nullable_to_non_nullable
              as List<DesktopWorkspaceFileItem>,
      openFileItems: null == openFileItems
          ? _self.openFileItems
          : openFileItems // ignore: cast_nullable_to_non_nullable
              as List<DesktopWorkspaceFileItem>,
      openFileIds: null == openFileIds
          ? _self.openFileIds
          : openFileIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
      selectedFile: freezed == selectedFile
          ? _self.selectedFile
          : selectedFile // ignore: cast_nullable_to_non_nullable
              as TodoFile?,
      selectedCategory: freezed == selectedCategory
          ? _self.selectedCategory
          : selectedCategory // ignore: cast_nullable_to_non_nullable
              as Category?,
      categories: null == categories
          ? _self.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<Category>,
      todos: null == todos
          ? _self.todos
          : todos // ignore: cast_nullable_to_non_nullable
              as List<Todo>,
      selectedTodo: freezed == selectedTodo
          ? _self.selectedTodo
          : selectedTodo // ignore: cast_nullable_to_non_nullable
              as Todo?,
      selectedTodoPath: null == selectedTodoPath
          ? _self.selectedTodoPath
          : selectedTodoPath // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }

  /// Create a copy of NotesWorkspaceViewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TodoFileCopyWith<$Res>? get selectedFile {
    if (_self.selectedFile == null) {
      return null;
    }

    return $TodoFileCopyWith<$Res>(_self.selectedFile!, (value) {
      return _then(_self.copyWith(selectedFile: value));
    });
  }

  /// Create a copy of NotesWorkspaceViewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CategoryCopyWith<$Res>? get selectedCategory {
    if (_self.selectedCategory == null) {
      return null;
    }

    return $CategoryCopyWith<$Res>(_self.selectedCategory!, (value) {
      return _then(_self.copyWith(selectedCategory: value));
    });
  }

  /// Create a copy of NotesWorkspaceViewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TodoCopyWith<$Res>? get selectedTodo {
    if (_self.selectedTodo == null) {
      return null;
    }

    return $TodoCopyWith<$Res>(_self.selectedTodo!, (value) {
      return _then(_self.copyWith(selectedTodo: value));
    });
  }
}

/// Adds pattern-matching-related methods to [NotesWorkspaceViewState].
extension NotesWorkspaceViewStatePatterns on NotesWorkspaceViewState {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_NotesWorkspaceViewState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NotesWorkspaceViewState() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_NotesWorkspaceViewState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotesWorkspaceViewState():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_NotesWorkspaceViewState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotesWorkspaceViewState() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            List<TodoFile> files,
            List<DesktopWorkspaceFileItem> fileItems,
            List<DesktopWorkspaceFileItem> openFileItems,
            List<int> openFileIds,
            TodoFile? selectedFile,
            Category? selectedCategory,
            List<Category> categories,
            List<Todo> todos,
            Todo? selectedTodo,
            List<int> selectedTodoPath)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NotesWorkspaceViewState() when $default != null:
        return $default(
            _that.files,
            _that.fileItems,
            _that.openFileItems,
            _that.openFileIds,
            _that.selectedFile,
            _that.selectedCategory,
            _that.categories,
            _that.todos,
            _that.selectedTodo,
            _that.selectedTodoPath);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            List<TodoFile> files,
            List<DesktopWorkspaceFileItem> fileItems,
            List<DesktopWorkspaceFileItem> openFileItems,
            List<int> openFileIds,
            TodoFile? selectedFile,
            Category? selectedCategory,
            List<Category> categories,
            List<Todo> todos,
            Todo? selectedTodo,
            List<int> selectedTodoPath)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotesWorkspaceViewState():
        return $default(
            _that.files,
            _that.fileItems,
            _that.openFileItems,
            _that.openFileIds,
            _that.selectedFile,
            _that.selectedCategory,
            _that.categories,
            _that.todos,
            _that.selectedTodo,
            _that.selectedTodoPath);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            List<TodoFile> files,
            List<DesktopWorkspaceFileItem> fileItems,
            List<DesktopWorkspaceFileItem> openFileItems,
            List<int> openFileIds,
            TodoFile? selectedFile,
            Category? selectedCategory,
            List<Category> categories,
            List<Todo> todos,
            Todo? selectedTodo,
            List<int> selectedTodoPath)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotesWorkspaceViewState() when $default != null:
        return $default(
            _that.files,
            _that.fileItems,
            _that.openFileItems,
            _that.openFileIds,
            _that.selectedFile,
            _that.selectedCategory,
            _that.categories,
            _that.todos,
            _that.selectedTodo,
            _that.selectedTodoPath);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _NotesWorkspaceViewState implements NotesWorkspaceViewState {
  const _NotesWorkspaceViewState(
      {final List<TodoFile> files = const <TodoFile>[],
      final List<DesktopWorkspaceFileItem> fileItems =
          const <DesktopWorkspaceFileItem>[],
      final List<DesktopWorkspaceFileItem> openFileItems =
          const <DesktopWorkspaceFileItem>[],
      final List<int> openFileIds = const <int>[],
      this.selectedFile,
      this.selectedCategory,
      final List<Category> categories = const <Category>[],
      final List<Todo> todos = const <Todo>[],
      this.selectedTodo,
      final List<int> selectedTodoPath = const <int>[]})
      : _files = files,
        _fileItems = fileItems,
        _openFileItems = openFileItems,
        _openFileIds = openFileIds,
        _categories = categories,
        _todos = todos,
        _selectedTodoPath = selectedTodoPath;

  final List<TodoFile> _files;
  @override
  @JsonKey()
  List<TodoFile> get files {
    if (_files is EqualUnmodifiableListView) return _files;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_files);
  }

  final List<DesktopWorkspaceFileItem> _fileItems;
  @override
  @JsonKey()
  List<DesktopWorkspaceFileItem> get fileItems {
    if (_fileItems is EqualUnmodifiableListView) return _fileItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fileItems);
  }

  final List<DesktopWorkspaceFileItem> _openFileItems;
  @override
  @JsonKey()
  List<DesktopWorkspaceFileItem> get openFileItems {
    if (_openFileItems is EqualUnmodifiableListView) return _openFileItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_openFileItems);
  }

  final List<int> _openFileIds;
  @override
  @JsonKey()
  List<int> get openFileIds {
    if (_openFileIds is EqualUnmodifiableListView) return _openFileIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_openFileIds);
  }

  @override
  final TodoFile? selectedFile;
  @override
  final Category? selectedCategory;
  final List<Category> _categories;
  @override
  @JsonKey()
  List<Category> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  final List<Todo> _todos;
  @override
  @JsonKey()
  List<Todo> get todos {
    if (_todos is EqualUnmodifiableListView) return _todos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_todos);
  }

  @override
  final Todo? selectedTodo;
  final List<int> _selectedTodoPath;
  @override
  @JsonKey()
  List<int> get selectedTodoPath {
    if (_selectedTodoPath is EqualUnmodifiableListView)
      return _selectedTodoPath;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedTodoPath);
  }

  /// Create a copy of NotesWorkspaceViewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NotesWorkspaceViewStateCopyWith<_NotesWorkspaceViewState> get copyWith =>
      __$NotesWorkspaceViewStateCopyWithImpl<_NotesWorkspaceViewState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _NotesWorkspaceViewState &&
            const DeepCollectionEquality().equals(other._files, _files) &&
            const DeepCollectionEquality()
                .equals(other._fileItems, _fileItems) &&
            const DeepCollectionEquality()
                .equals(other._openFileItems, _openFileItems) &&
            const DeepCollectionEquality()
                .equals(other._openFileIds, _openFileIds) &&
            (identical(other.selectedFile, selectedFile) ||
                other.selectedFile == selectedFile) &&
            (identical(other.selectedCategory, selectedCategory) ||
                other.selectedCategory == selectedCategory) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories) &&
            const DeepCollectionEquality().equals(other._todos, _todos) &&
            (identical(other.selectedTodo, selectedTodo) ||
                other.selectedTodo == selectedTodo) &&
            const DeepCollectionEquality()
                .equals(other._selectedTodoPath, _selectedTodoPath));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_files),
      const DeepCollectionEquality().hash(_fileItems),
      const DeepCollectionEquality().hash(_openFileItems),
      const DeepCollectionEquality().hash(_openFileIds),
      selectedFile,
      selectedCategory,
      const DeepCollectionEquality().hash(_categories),
      const DeepCollectionEquality().hash(_todos),
      selectedTodo,
      const DeepCollectionEquality().hash(_selectedTodoPath));

  @override
  String toString() {
    return 'NotesWorkspaceViewState(files: $files, fileItems: $fileItems, openFileItems: $openFileItems, openFileIds: $openFileIds, selectedFile: $selectedFile, selectedCategory: $selectedCategory, categories: $categories, todos: $todos, selectedTodo: $selectedTodo, selectedTodoPath: $selectedTodoPath)';
  }
}

/// @nodoc
abstract mixin class _$NotesWorkspaceViewStateCopyWith<$Res>
    implements $NotesWorkspaceViewStateCopyWith<$Res> {
  factory _$NotesWorkspaceViewStateCopyWith(_NotesWorkspaceViewState value,
          $Res Function(_NotesWorkspaceViewState) _then) =
      __$NotesWorkspaceViewStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<TodoFile> files,
      List<DesktopWorkspaceFileItem> fileItems,
      List<DesktopWorkspaceFileItem> openFileItems,
      List<int> openFileIds,
      TodoFile? selectedFile,
      Category? selectedCategory,
      List<Category> categories,
      List<Todo> todos,
      Todo? selectedTodo,
      List<int> selectedTodoPath});

  @override
  $TodoFileCopyWith<$Res>? get selectedFile;
  @override
  $CategoryCopyWith<$Res>? get selectedCategory;
  @override
  $TodoCopyWith<$Res>? get selectedTodo;
}

/// @nodoc
class __$NotesWorkspaceViewStateCopyWithImpl<$Res>
    implements _$NotesWorkspaceViewStateCopyWith<$Res> {
  __$NotesWorkspaceViewStateCopyWithImpl(this._self, this._then);

  final _NotesWorkspaceViewState _self;
  final $Res Function(_NotesWorkspaceViewState) _then;

  /// Create a copy of NotesWorkspaceViewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? files = null,
    Object? fileItems = null,
    Object? openFileItems = null,
    Object? openFileIds = null,
    Object? selectedFile = freezed,
    Object? selectedCategory = freezed,
    Object? categories = null,
    Object? todos = null,
    Object? selectedTodo = freezed,
    Object? selectedTodoPath = null,
  }) {
    return _then(_NotesWorkspaceViewState(
      files: null == files
          ? _self._files
          : files // ignore: cast_nullable_to_non_nullable
              as List<TodoFile>,
      fileItems: null == fileItems
          ? _self._fileItems
          : fileItems // ignore: cast_nullable_to_non_nullable
              as List<DesktopWorkspaceFileItem>,
      openFileItems: null == openFileItems
          ? _self._openFileItems
          : openFileItems // ignore: cast_nullable_to_non_nullable
              as List<DesktopWorkspaceFileItem>,
      openFileIds: null == openFileIds
          ? _self._openFileIds
          : openFileIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
      selectedFile: freezed == selectedFile
          ? _self.selectedFile
          : selectedFile // ignore: cast_nullable_to_non_nullable
              as TodoFile?,
      selectedCategory: freezed == selectedCategory
          ? _self.selectedCategory
          : selectedCategory // ignore: cast_nullable_to_non_nullable
              as Category?,
      categories: null == categories
          ? _self._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<Category>,
      todos: null == todos
          ? _self._todos
          : todos // ignore: cast_nullable_to_non_nullable
              as List<Todo>,
      selectedTodo: freezed == selectedTodo
          ? _self.selectedTodo
          : selectedTodo // ignore: cast_nullable_to_non_nullable
              as Todo?,
      selectedTodoPath: null == selectedTodoPath
          ? _self._selectedTodoPath
          : selectedTodoPath // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }

  /// Create a copy of NotesWorkspaceViewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TodoFileCopyWith<$Res>? get selectedFile {
    if (_self.selectedFile == null) {
      return null;
    }

    return $TodoFileCopyWith<$Res>(_self.selectedFile!, (value) {
      return _then(_self.copyWith(selectedFile: value));
    });
  }

  /// Create a copy of NotesWorkspaceViewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CategoryCopyWith<$Res>? get selectedCategory {
    if (_self.selectedCategory == null) {
      return null;
    }

    return $CategoryCopyWith<$Res>(_self.selectedCategory!, (value) {
      return _then(_self.copyWith(selectedCategory: value));
    });
  }

  /// Create a copy of NotesWorkspaceViewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TodoCopyWith<$Res>? get selectedTodo {
    if (_self.selectedTodo == null) {
      return null;
    }

    return $TodoCopyWith<$Res>(_self.selectedTodo!, (value) {
      return _then(_self.copyWith(selectedTodo: value));
    });
  }
}

/// @nodoc
mixin _$DesktopWorkspaceFileItem {
  TodoFile get file;
  int get categoryCount;
  bool get isSelected;
  bool get isOpen;

  /// Create a copy of DesktopWorkspaceFileItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DesktopWorkspaceFileItemCopyWith<DesktopWorkspaceFileItem> get copyWith =>
      _$DesktopWorkspaceFileItemCopyWithImpl<DesktopWorkspaceFileItem>(
          this as DesktopWorkspaceFileItem, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DesktopWorkspaceFileItem &&
            (identical(other.file, file) || other.file == file) &&
            (identical(other.categoryCount, categoryCount) ||
                other.categoryCount == categoryCount) &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected) &&
            (identical(other.isOpen, isOpen) || other.isOpen == isOpen));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, file, categoryCount, isSelected, isOpen);

  @override
  String toString() {
    return 'DesktopWorkspaceFileItem(file: $file, categoryCount: $categoryCount, isSelected: $isSelected, isOpen: $isOpen)';
  }
}

/// @nodoc
abstract mixin class $DesktopWorkspaceFileItemCopyWith<$Res> {
  factory $DesktopWorkspaceFileItemCopyWith(DesktopWorkspaceFileItem value,
          $Res Function(DesktopWorkspaceFileItem) _then) =
      _$DesktopWorkspaceFileItemCopyWithImpl;
  @useResult
  $Res call({TodoFile file, int categoryCount, bool isSelected, bool isOpen});

  $TodoFileCopyWith<$Res> get file;
}

/// @nodoc
class _$DesktopWorkspaceFileItemCopyWithImpl<$Res>
    implements $DesktopWorkspaceFileItemCopyWith<$Res> {
  _$DesktopWorkspaceFileItemCopyWithImpl(this._self, this._then);

  final DesktopWorkspaceFileItem _self;
  final $Res Function(DesktopWorkspaceFileItem) _then;

  /// Create a copy of DesktopWorkspaceFileItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? file = null,
    Object? categoryCount = null,
    Object? isSelected = null,
    Object? isOpen = null,
  }) {
    return _then(_self.copyWith(
      file: null == file
          ? _self.file
          : file // ignore: cast_nullable_to_non_nullable
              as TodoFile,
      categoryCount: null == categoryCount
          ? _self.categoryCount
          : categoryCount // ignore: cast_nullable_to_non_nullable
              as int,
      isSelected: null == isSelected
          ? _self.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
      isOpen: null == isOpen
          ? _self.isOpen
          : isOpen // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of DesktopWorkspaceFileItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TodoFileCopyWith<$Res> get file {
    return $TodoFileCopyWith<$Res>(_self.file, (value) {
      return _then(_self.copyWith(file: value));
    });
  }
}

/// Adds pattern-matching-related methods to [DesktopWorkspaceFileItem].
extension DesktopWorkspaceFileItemPatterns on DesktopWorkspaceFileItem {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_DesktopWorkspaceFileItem value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DesktopWorkspaceFileItem() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_DesktopWorkspaceFileItem value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DesktopWorkspaceFileItem():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_DesktopWorkspaceFileItem value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DesktopWorkspaceFileItem() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            TodoFile file, int categoryCount, bool isSelected, bool isOpen)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DesktopWorkspaceFileItem() when $default != null:
        return $default(
            _that.file, _that.categoryCount, _that.isSelected, _that.isOpen);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            TodoFile file, int categoryCount, bool isSelected, bool isOpen)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DesktopWorkspaceFileItem():
        return $default(
            _that.file, _that.categoryCount, _that.isSelected, _that.isOpen);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            TodoFile file, int categoryCount, bool isSelected, bool isOpen)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DesktopWorkspaceFileItem() when $default != null:
        return $default(
            _that.file, _that.categoryCount, _that.isSelected, _that.isOpen);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _DesktopWorkspaceFileItem implements DesktopWorkspaceFileItem {
  const _DesktopWorkspaceFileItem(
      {required this.file,
      this.categoryCount = 0,
      this.isSelected = false,
      this.isOpen = false});

  @override
  final TodoFile file;
  @override
  @JsonKey()
  final int categoryCount;
  @override
  @JsonKey()
  final bool isSelected;
  @override
  @JsonKey()
  final bool isOpen;

  /// Create a copy of DesktopWorkspaceFileItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DesktopWorkspaceFileItemCopyWith<_DesktopWorkspaceFileItem> get copyWith =>
      __$DesktopWorkspaceFileItemCopyWithImpl<_DesktopWorkspaceFileItem>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DesktopWorkspaceFileItem &&
            (identical(other.file, file) || other.file == file) &&
            (identical(other.categoryCount, categoryCount) ||
                other.categoryCount == categoryCount) &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected) &&
            (identical(other.isOpen, isOpen) || other.isOpen == isOpen));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, file, categoryCount, isSelected, isOpen);

  @override
  String toString() {
    return 'DesktopWorkspaceFileItem(file: $file, categoryCount: $categoryCount, isSelected: $isSelected, isOpen: $isOpen)';
  }
}

/// @nodoc
abstract mixin class _$DesktopWorkspaceFileItemCopyWith<$Res>
    implements $DesktopWorkspaceFileItemCopyWith<$Res> {
  factory _$DesktopWorkspaceFileItemCopyWith(_DesktopWorkspaceFileItem value,
          $Res Function(_DesktopWorkspaceFileItem) _then) =
      __$DesktopWorkspaceFileItemCopyWithImpl;
  @override
  @useResult
  $Res call({TodoFile file, int categoryCount, bool isSelected, bool isOpen});

  @override
  $TodoFileCopyWith<$Res> get file;
}

/// @nodoc
class __$DesktopWorkspaceFileItemCopyWithImpl<$Res>
    implements _$DesktopWorkspaceFileItemCopyWith<$Res> {
  __$DesktopWorkspaceFileItemCopyWithImpl(this._self, this._then);

  final _DesktopWorkspaceFileItem _self;
  final $Res Function(_DesktopWorkspaceFileItem) _then;

  /// Create a copy of DesktopWorkspaceFileItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? file = null,
    Object? categoryCount = null,
    Object? isSelected = null,
    Object? isOpen = null,
  }) {
    return _then(_DesktopWorkspaceFileItem(
      file: null == file
          ? _self.file
          : file // ignore: cast_nullable_to_non_nullable
              as TodoFile,
      categoryCount: null == categoryCount
          ? _self.categoryCount
          : categoryCount // ignore: cast_nullable_to_non_nullable
              as int,
      isSelected: null == isSelected
          ? _self.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
      isOpen: null == isOpen
          ? _self.isOpen
          : isOpen // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of DesktopWorkspaceFileItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TodoFileCopyWith<$Res> get file {
    return $TodoFileCopyWith<$Res>(_self.file, (value) {
      return _then(_self.copyWith(file: value));
    });
  }
}

// dart format on
