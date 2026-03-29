// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mobile_note_detail_view_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MobileNoteDetailViewState {
  String get fileName;
  List<MobileNoteDetailCategoryItem> get categories;
  bool get isLoading;

  /// Create a copy of MobileNoteDetailViewState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MobileNoteDetailViewStateCopyWith<MobileNoteDetailViewState> get copyWith =>
      _$MobileNoteDetailViewStateCopyWithImpl<MobileNoteDetailViewState>(
          this as MobileNoteDetailViewState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MobileNoteDetailViewState &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            const DeepCollectionEquality()
                .equals(other.categories, categories) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading));
  }

  @override
  int get hashCode => Object.hash(runtimeType, fileName,
      const DeepCollectionEquality().hash(categories), isLoading);

  @override
  String toString() {
    return 'MobileNoteDetailViewState(fileName: $fileName, categories: $categories, isLoading: $isLoading)';
  }
}

/// @nodoc
abstract mixin class $MobileNoteDetailViewStateCopyWith<$Res> {
  factory $MobileNoteDetailViewStateCopyWith(MobileNoteDetailViewState value,
          $Res Function(MobileNoteDetailViewState) _then) =
      _$MobileNoteDetailViewStateCopyWithImpl;
  @useResult
  $Res call(
      {String fileName,
      List<MobileNoteDetailCategoryItem> categories,
      bool isLoading});
}

/// @nodoc
class _$MobileNoteDetailViewStateCopyWithImpl<$Res>
    implements $MobileNoteDetailViewStateCopyWith<$Res> {
  _$MobileNoteDetailViewStateCopyWithImpl(this._self, this._then);

  final MobileNoteDetailViewState _self;
  final $Res Function(MobileNoteDetailViewState) _then;

  /// Create a copy of MobileNoteDetailViewState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileName = null,
    Object? categories = null,
    Object? isLoading = null,
  }) {
    return _then(_self.copyWith(
      fileName: null == fileName
          ? _self.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      categories: null == categories
          ? _self.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<MobileNoteDetailCategoryItem>,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [MobileNoteDetailViewState].
extension MobileNoteDetailViewStatePatterns on MobileNoteDetailViewState {
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
    TResult Function(_MobileNoteDetailViewState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MobileNoteDetailViewState() when $default != null:
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
    TResult Function(_MobileNoteDetailViewState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MobileNoteDetailViewState():
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
    TResult? Function(_MobileNoteDetailViewState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MobileNoteDetailViewState() when $default != null:
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
    TResult Function(String fileName,
            List<MobileNoteDetailCategoryItem> categories, bool isLoading)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MobileNoteDetailViewState() when $default != null:
        return $default(_that.fileName, _that.categories, _that.isLoading);
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
    TResult Function(String fileName,
            List<MobileNoteDetailCategoryItem> categories, bool isLoading)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MobileNoteDetailViewState():
        return $default(_that.fileName, _that.categories, _that.isLoading);
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
    TResult? Function(String fileName,
            List<MobileNoteDetailCategoryItem> categories, bool isLoading)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MobileNoteDetailViewState() when $default != null:
        return $default(_that.fileName, _that.categories, _that.isLoading);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _MobileNoteDetailViewState implements MobileNoteDetailViewState {
  const _MobileNoteDetailViewState(
      {required this.fileName,
      final List<MobileNoteDetailCategoryItem> categories =
          const <MobileNoteDetailCategoryItem>[],
      this.isLoading = false})
      : _categories = categories;

  @override
  final String fileName;
  final List<MobileNoteDetailCategoryItem> _categories;
  @override
  @JsonKey()
  List<MobileNoteDetailCategoryItem> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  @override
  @JsonKey()
  final bool isLoading;

  /// Create a copy of MobileNoteDetailViewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MobileNoteDetailViewStateCopyWith<_MobileNoteDetailViewState>
      get copyWith =>
          __$MobileNoteDetailViewStateCopyWithImpl<_MobileNoteDetailViewState>(
              this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MobileNoteDetailViewState &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading));
  }

  @override
  int get hashCode => Object.hash(runtimeType, fileName,
      const DeepCollectionEquality().hash(_categories), isLoading);

  @override
  String toString() {
    return 'MobileNoteDetailViewState(fileName: $fileName, categories: $categories, isLoading: $isLoading)';
  }
}

/// @nodoc
abstract mixin class _$MobileNoteDetailViewStateCopyWith<$Res>
    implements $MobileNoteDetailViewStateCopyWith<$Res> {
  factory _$MobileNoteDetailViewStateCopyWith(_MobileNoteDetailViewState value,
          $Res Function(_MobileNoteDetailViewState) _then) =
      __$MobileNoteDetailViewStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String fileName,
      List<MobileNoteDetailCategoryItem> categories,
      bool isLoading});
}

/// @nodoc
class __$MobileNoteDetailViewStateCopyWithImpl<$Res>
    implements _$MobileNoteDetailViewStateCopyWith<$Res> {
  __$MobileNoteDetailViewStateCopyWithImpl(this._self, this._then);

  final _MobileNoteDetailViewState _self;
  final $Res Function(_MobileNoteDetailViewState) _then;

  /// Create a copy of MobileNoteDetailViewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? fileName = null,
    Object? categories = null,
    Object? isLoading = null,
  }) {
    return _then(_MobileNoteDetailViewState(
      fileName: null == fileName
          ? _self.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      categories: null == categories
          ? _self._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<MobileNoteDetailCategoryItem>,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$MobileNoteDetailCategoryItem {
  Category get category;
  int get topLevelTodoCount;

  /// Create a copy of MobileNoteDetailCategoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MobileNoteDetailCategoryItemCopyWith<MobileNoteDetailCategoryItem>
      get copyWith => _$MobileNoteDetailCategoryItemCopyWithImpl<
              MobileNoteDetailCategoryItem>(
          this as MobileNoteDetailCategoryItem, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MobileNoteDetailCategoryItem &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.topLevelTodoCount, topLevelTodoCount) ||
                other.topLevelTodoCount == topLevelTodoCount));
  }

  @override
  int get hashCode => Object.hash(runtimeType, category, topLevelTodoCount);

  @override
  String toString() {
    return 'MobileNoteDetailCategoryItem(category: $category, topLevelTodoCount: $topLevelTodoCount)';
  }
}

/// @nodoc
abstract mixin class $MobileNoteDetailCategoryItemCopyWith<$Res> {
  factory $MobileNoteDetailCategoryItemCopyWith(
          MobileNoteDetailCategoryItem value,
          $Res Function(MobileNoteDetailCategoryItem) _then) =
      _$MobileNoteDetailCategoryItemCopyWithImpl;
  @useResult
  $Res call({Category category, int topLevelTodoCount});

  $CategoryCopyWith<$Res> get category;
}

/// @nodoc
class _$MobileNoteDetailCategoryItemCopyWithImpl<$Res>
    implements $MobileNoteDetailCategoryItemCopyWith<$Res> {
  _$MobileNoteDetailCategoryItemCopyWithImpl(this._self, this._then);

  final MobileNoteDetailCategoryItem _self;
  final $Res Function(MobileNoteDetailCategoryItem) _then;

  /// Create a copy of MobileNoteDetailCategoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? topLevelTodoCount = null,
  }) {
    return _then(_self.copyWith(
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as Category,
      topLevelTodoCount: null == topLevelTodoCount
          ? _self.topLevelTodoCount
          : topLevelTodoCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of MobileNoteDetailCategoryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CategoryCopyWith<$Res> get category {
    return $CategoryCopyWith<$Res>(_self.category, (value) {
      return _then(_self.copyWith(category: value));
    });
  }
}

/// Adds pattern-matching-related methods to [MobileNoteDetailCategoryItem].
extension MobileNoteDetailCategoryItemPatterns on MobileNoteDetailCategoryItem {
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
    TResult Function(_MobileNoteDetailCategoryItem value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MobileNoteDetailCategoryItem() when $default != null:
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
    TResult Function(_MobileNoteDetailCategoryItem value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MobileNoteDetailCategoryItem():
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
    TResult? Function(_MobileNoteDetailCategoryItem value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MobileNoteDetailCategoryItem() when $default != null:
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
    TResult Function(Category category, int topLevelTodoCount)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MobileNoteDetailCategoryItem() when $default != null:
        return $default(_that.category, _that.topLevelTodoCount);
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
    TResult Function(Category category, int topLevelTodoCount) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MobileNoteDetailCategoryItem():
        return $default(_that.category, _that.topLevelTodoCount);
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
    TResult? Function(Category category, int topLevelTodoCount)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MobileNoteDetailCategoryItem() when $default != null:
        return $default(_that.category, _that.topLevelTodoCount);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _MobileNoteDetailCategoryItem implements MobileNoteDetailCategoryItem {
  const _MobileNoteDetailCategoryItem(
      {required this.category, this.topLevelTodoCount = 0});

  @override
  final Category category;
  @override
  @JsonKey()
  final int topLevelTodoCount;

  /// Create a copy of MobileNoteDetailCategoryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MobileNoteDetailCategoryItemCopyWith<_MobileNoteDetailCategoryItem>
      get copyWith => __$MobileNoteDetailCategoryItemCopyWithImpl<
          _MobileNoteDetailCategoryItem>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MobileNoteDetailCategoryItem &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.topLevelTodoCount, topLevelTodoCount) ||
                other.topLevelTodoCount == topLevelTodoCount));
  }

  @override
  int get hashCode => Object.hash(runtimeType, category, topLevelTodoCount);

  @override
  String toString() {
    return 'MobileNoteDetailCategoryItem(category: $category, topLevelTodoCount: $topLevelTodoCount)';
  }
}

/// @nodoc
abstract mixin class _$MobileNoteDetailCategoryItemCopyWith<$Res>
    implements $MobileNoteDetailCategoryItemCopyWith<$Res> {
  factory _$MobileNoteDetailCategoryItemCopyWith(
          _MobileNoteDetailCategoryItem value,
          $Res Function(_MobileNoteDetailCategoryItem) _then) =
      __$MobileNoteDetailCategoryItemCopyWithImpl;
  @override
  @useResult
  $Res call({Category category, int topLevelTodoCount});

  @override
  $CategoryCopyWith<$Res> get category;
}

/// @nodoc
class __$MobileNoteDetailCategoryItemCopyWithImpl<$Res>
    implements _$MobileNoteDetailCategoryItemCopyWith<$Res> {
  __$MobileNoteDetailCategoryItemCopyWithImpl(this._self, this._then);

  final _MobileNoteDetailCategoryItem _self;
  final $Res Function(_MobileNoteDetailCategoryItem) _then;

  /// Create a copy of MobileNoteDetailCategoryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? category = null,
    Object? topLevelTodoCount = null,
  }) {
    return _then(_MobileNoteDetailCategoryItem(
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as Category,
      topLevelTodoCount: null == topLevelTodoCount
          ? _self.topLevelTodoCount
          : topLevelTodoCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of MobileNoteDetailCategoryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CategoryCopyWith<$Res> get category {
    return $CategoryCopyWith<$Res>(_self.category, (value) {
      return _then(_self.copyWith(category: value));
    });
  }
}

// dart format on
