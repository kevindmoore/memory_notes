// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_result_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SearchResultItem {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is SearchResultItem);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'SearchResultItem()';
  }
}

/// @nodoc
class $SearchResultItemCopyWith<$Res> {
  $SearchResultItemCopyWith(
      SearchResultItem _, $Res Function(SearchResultItem) __);
}

/// Adds pattern-matching-related methods to [SearchResultItem].
extension SearchResultItemPatterns on SearchResultItem {
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
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SearchFileResultItem value)? file,
    TResult Function(SearchCategoryResultItem value)? category,
    TResult Function(SearchTodoResultItem value)? todo,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case SearchFileResultItem() when file != null:
        return file(_that);
      case SearchCategoryResultItem() when category != null:
        return category(_that);
      case SearchTodoResultItem() when todo != null:
        return todo(_that);
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
  TResult map<TResult extends Object?>({
    required TResult Function(SearchFileResultItem value) file,
    required TResult Function(SearchCategoryResultItem value) category,
    required TResult Function(SearchTodoResultItem value) todo,
  }) {
    final _that = this;
    switch (_that) {
      case SearchFileResultItem():
        return file(_that);
      case SearchCategoryResultItem():
        return category(_that);
      case SearchTodoResultItem():
        return todo(_that);
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
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SearchFileResultItem value)? file,
    TResult? Function(SearchCategoryResultItem value)? category,
    TResult? Function(SearchTodoResultItem value)? todo,
  }) {
    final _that = this;
    switch (_that) {
      case SearchFileResultItem() when file != null:
        return file(_that);
      case SearchCategoryResultItem() when category != null:
        return category(_that);
      case SearchTodoResultItem() when todo != null:
        return todo(_that);
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
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(TodoFile file)? file,
    TResult Function(Category category, TodoFile parentFile, String subtitle)?
        category,
    TResult Function(Todo todo, List<int> ancestorTodoIds,
            Category parentCategory, TodoFile parentFile, String subtitle)?
        todo,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case SearchFileResultItem() when file != null:
        return file(_that.file);
      case SearchCategoryResultItem() when category != null:
        return category(_that.category, _that.parentFile, _that.subtitle);
      case SearchTodoResultItem() when todo != null:
        return todo(_that.todo, _that.ancestorTodoIds, _that.parentCategory,
            _that.parentFile, _that.subtitle);
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
  TResult when<TResult extends Object?>({
    required TResult Function(TodoFile file) file,
    required TResult Function(
            Category category, TodoFile parentFile, String subtitle)
        category,
    required TResult Function(Todo todo, List<int> ancestorTodoIds,
            Category parentCategory, TodoFile parentFile, String subtitle)
        todo,
  }) {
    final _that = this;
    switch (_that) {
      case SearchFileResultItem():
        return file(_that.file);
      case SearchCategoryResultItem():
        return category(_that.category, _that.parentFile, _that.subtitle);
      case SearchTodoResultItem():
        return todo(_that.todo, _that.ancestorTodoIds, _that.parentCategory,
            _that.parentFile, _that.subtitle);
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
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(TodoFile file)? file,
    TResult? Function(Category category, TodoFile parentFile, String subtitle)?
        category,
    TResult? Function(Todo todo, List<int> ancestorTodoIds,
            Category parentCategory, TodoFile parentFile, String subtitle)?
        todo,
  }) {
    final _that = this;
    switch (_that) {
      case SearchFileResultItem() when file != null:
        return file(_that.file);
      case SearchCategoryResultItem() when category != null:
        return category(_that.category, _that.parentFile, _that.subtitle);
      case SearchTodoResultItem() when todo != null:
        return todo(_that.todo, _that.ancestorTodoIds, _that.parentCategory,
            _that.parentFile, _that.subtitle);
      case _:
        return null;
    }
  }
}

/// @nodoc

class SearchFileResultItem implements SearchResultItem {
  const SearchFileResultItem({required this.file});

  final TodoFile file;

  /// Create a copy of SearchResultItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SearchFileResultItemCopyWith<SearchFileResultItem> get copyWith =>
      _$SearchFileResultItemCopyWithImpl<SearchFileResultItem>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SearchFileResultItem &&
            (identical(other.file, file) || other.file == file));
  }

  @override
  int get hashCode => Object.hash(runtimeType, file);

  @override
  String toString() {
    return 'SearchResultItem.file(file: $file)';
  }
}

/// @nodoc
abstract mixin class $SearchFileResultItemCopyWith<$Res>
    implements $SearchResultItemCopyWith<$Res> {
  factory $SearchFileResultItemCopyWith(SearchFileResultItem value,
          $Res Function(SearchFileResultItem) _then) =
      _$SearchFileResultItemCopyWithImpl;
  @useResult
  $Res call({TodoFile file});

  $TodoFileCopyWith<$Res> get file;
}

/// @nodoc
class _$SearchFileResultItemCopyWithImpl<$Res>
    implements $SearchFileResultItemCopyWith<$Res> {
  _$SearchFileResultItemCopyWithImpl(this._self, this._then);

  final SearchFileResultItem _self;
  final $Res Function(SearchFileResultItem) _then;

  /// Create a copy of SearchResultItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? file = null,
  }) {
    return _then(SearchFileResultItem(
      file: null == file
          ? _self.file
          : file // ignore: cast_nullable_to_non_nullable
              as TodoFile,
    ));
  }

  /// Create a copy of SearchResultItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TodoFileCopyWith<$Res> get file {
    return $TodoFileCopyWith<$Res>(_self.file, (value) {
      return _then(_self.copyWith(file: value));
    });
  }
}

/// @nodoc

class SearchCategoryResultItem implements SearchResultItem {
  const SearchCategoryResultItem(
      {required this.category,
      required this.parentFile,
      required this.subtitle});

  final Category category;
  final TodoFile parentFile;
  final String subtitle;

  /// Create a copy of SearchResultItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SearchCategoryResultItemCopyWith<SearchCategoryResultItem> get copyWith =>
      _$SearchCategoryResultItemCopyWithImpl<SearchCategoryResultItem>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SearchCategoryResultItem &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.parentFile, parentFile) ||
                other.parentFile == parentFile) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle));
  }

  @override
  int get hashCode => Object.hash(runtimeType, category, parentFile, subtitle);

  @override
  String toString() {
    return 'SearchResultItem.category(category: $category, parentFile: $parentFile, subtitle: $subtitle)';
  }
}

/// @nodoc
abstract mixin class $SearchCategoryResultItemCopyWith<$Res>
    implements $SearchResultItemCopyWith<$Res> {
  factory $SearchCategoryResultItemCopyWith(SearchCategoryResultItem value,
          $Res Function(SearchCategoryResultItem) _then) =
      _$SearchCategoryResultItemCopyWithImpl;
  @useResult
  $Res call({Category category, TodoFile parentFile, String subtitle});

  $CategoryCopyWith<$Res> get category;
  $TodoFileCopyWith<$Res> get parentFile;
}

/// @nodoc
class _$SearchCategoryResultItemCopyWithImpl<$Res>
    implements $SearchCategoryResultItemCopyWith<$Res> {
  _$SearchCategoryResultItemCopyWithImpl(this._self, this._then);

  final SearchCategoryResultItem _self;
  final $Res Function(SearchCategoryResultItem) _then;

  /// Create a copy of SearchResultItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? category = null,
    Object? parentFile = null,
    Object? subtitle = null,
  }) {
    return _then(SearchCategoryResultItem(
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as Category,
      parentFile: null == parentFile
          ? _self.parentFile
          : parentFile // ignore: cast_nullable_to_non_nullable
              as TodoFile,
      subtitle: null == subtitle
          ? _self.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }

  /// Create a copy of SearchResultItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CategoryCopyWith<$Res> get category {
    return $CategoryCopyWith<$Res>(_self.category, (value) {
      return _then(_self.copyWith(category: value));
    });
  }

  /// Create a copy of SearchResultItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TodoFileCopyWith<$Res> get parentFile {
    return $TodoFileCopyWith<$Res>(_self.parentFile, (value) {
      return _then(_self.copyWith(parentFile: value));
    });
  }
}

/// @nodoc

class SearchTodoResultItem implements SearchResultItem {
  const SearchTodoResultItem(
      {required this.todo,
      required final List<int> ancestorTodoIds,
      required this.parentCategory,
      required this.parentFile,
      required this.subtitle})
      : _ancestorTodoIds = ancestorTodoIds;

  final Todo todo;
  final List<int> _ancestorTodoIds;
  List<int> get ancestorTodoIds {
    if (_ancestorTodoIds is EqualUnmodifiableListView) return _ancestorTodoIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ancestorTodoIds);
  }

  final Category parentCategory;
  final TodoFile parentFile;
  final String subtitle;

  /// Create a copy of SearchResultItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SearchTodoResultItemCopyWith<SearchTodoResultItem> get copyWith =>
      _$SearchTodoResultItemCopyWithImpl<SearchTodoResultItem>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SearchTodoResultItem &&
            (identical(other.todo, todo) || other.todo == todo) &&
            const DeepCollectionEquality()
                .equals(other._ancestorTodoIds, _ancestorTodoIds) &&
            (identical(other.parentCategory, parentCategory) ||
                other.parentCategory == parentCategory) &&
            (identical(other.parentFile, parentFile) ||
                other.parentFile == parentFile) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      todo,
      const DeepCollectionEquality().hash(_ancestorTodoIds),
      parentCategory,
      parentFile,
      subtitle);

  @override
  String toString() {
    return 'SearchResultItem.todo(todo: $todo, ancestorTodoIds: $ancestorTodoIds, parentCategory: $parentCategory, parentFile: $parentFile, subtitle: $subtitle)';
  }
}

/// @nodoc
abstract mixin class $SearchTodoResultItemCopyWith<$Res>
    implements $SearchResultItemCopyWith<$Res> {
  factory $SearchTodoResultItemCopyWith(SearchTodoResultItem value,
          $Res Function(SearchTodoResultItem) _then) =
      _$SearchTodoResultItemCopyWithImpl;
  @useResult
  $Res call(
      {Todo todo,
      List<int> ancestorTodoIds,
      Category parentCategory,
      TodoFile parentFile,
      String subtitle});

  $TodoCopyWith<$Res> get todo;
  $CategoryCopyWith<$Res> get parentCategory;
  $TodoFileCopyWith<$Res> get parentFile;
}

/// @nodoc
class _$SearchTodoResultItemCopyWithImpl<$Res>
    implements $SearchTodoResultItemCopyWith<$Res> {
  _$SearchTodoResultItemCopyWithImpl(this._self, this._then);

  final SearchTodoResultItem _self;
  final $Res Function(SearchTodoResultItem) _then;

  /// Create a copy of SearchResultItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? todo = null,
    Object? ancestorTodoIds = null,
    Object? parentCategory = null,
    Object? parentFile = null,
    Object? subtitle = null,
  }) {
    return _then(SearchTodoResultItem(
      todo: null == todo
          ? _self.todo
          : todo // ignore: cast_nullable_to_non_nullable
              as Todo,
      ancestorTodoIds: null == ancestorTodoIds
          ? _self._ancestorTodoIds
          : ancestorTodoIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
      parentCategory: null == parentCategory
          ? _self.parentCategory
          : parentCategory // ignore: cast_nullable_to_non_nullable
              as Category,
      parentFile: null == parentFile
          ? _self.parentFile
          : parentFile // ignore: cast_nullable_to_non_nullable
              as TodoFile,
      subtitle: null == subtitle
          ? _self.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }

  /// Create a copy of SearchResultItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TodoCopyWith<$Res> get todo {
    return $TodoCopyWith<$Res>(_self.todo, (value) {
      return _then(_self.copyWith(todo: value));
    });
  }

  /// Create a copy of SearchResultItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CategoryCopyWith<$Res> get parentCategory {
    return $CategoryCopyWith<$Res>(_self.parentCategory, (value) {
      return _then(_self.copyWith(parentCategory: value));
    });
  }

  /// Create a copy of SearchResultItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TodoFileCopyWith<$Res> get parentFile {
    return $TodoFileCopyWith<$Res>(_self.parentFile, (value) {
      return _then(_self.copyWith(parentFile: value));
    });
  }
}

// dart format on
