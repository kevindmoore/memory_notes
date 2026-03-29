// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notes_workspace_selection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotesWorkspaceSelection {
  int? get fileId;
  int? get categoryId;
  int? get todoId;
  List<int> get todoPath;

  /// Create a copy of NotesWorkspaceSelection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NotesWorkspaceSelectionCopyWith<NotesWorkspaceSelection> get copyWith =>
      _$NotesWorkspaceSelectionCopyWithImpl<NotesWorkspaceSelection>(
          this as NotesWorkspaceSelection, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NotesWorkspaceSelection &&
            (identical(other.fileId, fileId) || other.fileId == fileId) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.todoId, todoId) || other.todoId == todoId) &&
            const DeepCollectionEquality().equals(other.todoPath, todoPath));
  }

  @override
  int get hashCode => Object.hash(runtimeType, fileId, categoryId, todoId,
      const DeepCollectionEquality().hash(todoPath));

  @override
  String toString() {
    return 'NotesWorkspaceSelection(fileId: $fileId, categoryId: $categoryId, todoId: $todoId, todoPath: $todoPath)';
  }
}

/// @nodoc
abstract mixin class $NotesWorkspaceSelectionCopyWith<$Res> {
  factory $NotesWorkspaceSelectionCopyWith(NotesWorkspaceSelection value,
          $Res Function(NotesWorkspaceSelection) _then) =
      _$NotesWorkspaceSelectionCopyWithImpl;
  @useResult
  $Res call({int? fileId, int? categoryId, int? todoId, List<int> todoPath});
}

/// @nodoc
class _$NotesWorkspaceSelectionCopyWithImpl<$Res>
    implements $NotesWorkspaceSelectionCopyWith<$Res> {
  _$NotesWorkspaceSelectionCopyWithImpl(this._self, this._then);

  final NotesWorkspaceSelection _self;
  final $Res Function(NotesWorkspaceSelection) _then;

  /// Create a copy of NotesWorkspaceSelection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileId = freezed,
    Object? categoryId = freezed,
    Object? todoId = freezed,
    Object? todoPath = null,
  }) {
    return _then(_self.copyWith(
      fileId: freezed == fileId
          ? _self.fileId
          : fileId // ignore: cast_nullable_to_non_nullable
              as int?,
      categoryId: freezed == categoryId
          ? _self.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int?,
      todoId: freezed == todoId
          ? _self.todoId
          : todoId // ignore: cast_nullable_to_non_nullable
              as int?,
      todoPath: null == todoPath
          ? _self.todoPath
          : todoPath // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }
}

/// Adds pattern-matching-related methods to [NotesWorkspaceSelection].
extension NotesWorkspaceSelectionPatterns on NotesWorkspaceSelection {
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
    TResult Function(_NotesWorkspaceSelection value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NotesWorkspaceSelection() when $default != null:
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
    TResult Function(_NotesWorkspaceSelection value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotesWorkspaceSelection():
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
    TResult? Function(_NotesWorkspaceSelection value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotesWorkspaceSelection() when $default != null:
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
            int? fileId, int? categoryId, int? todoId, List<int> todoPath)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NotesWorkspaceSelection() when $default != null:
        return $default(
            _that.fileId, _that.categoryId, _that.todoId, _that.todoPath);
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
            int? fileId, int? categoryId, int? todoId, List<int> todoPath)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotesWorkspaceSelection():
        return $default(
            _that.fileId, _that.categoryId, _that.todoId, _that.todoPath);
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
            int? fileId, int? categoryId, int? todoId, List<int> todoPath)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotesWorkspaceSelection() when $default != null:
        return $default(
            _that.fileId, _that.categoryId, _that.todoId, _that.todoPath);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _NotesWorkspaceSelection implements NotesWorkspaceSelection {
  const _NotesWorkspaceSelection(
      {this.fileId,
      this.categoryId,
      this.todoId,
      final List<int> todoPath = const <int>[]})
      : _todoPath = todoPath;

  @override
  final int? fileId;
  @override
  final int? categoryId;
  @override
  final int? todoId;
  final List<int> _todoPath;
  @override
  @JsonKey()
  List<int> get todoPath {
    if (_todoPath is EqualUnmodifiableListView) return _todoPath;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_todoPath);
  }

  /// Create a copy of NotesWorkspaceSelection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NotesWorkspaceSelectionCopyWith<_NotesWorkspaceSelection> get copyWith =>
      __$NotesWorkspaceSelectionCopyWithImpl<_NotesWorkspaceSelection>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _NotesWorkspaceSelection &&
            (identical(other.fileId, fileId) || other.fileId == fileId) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.todoId, todoId) || other.todoId == todoId) &&
            const DeepCollectionEquality().equals(other._todoPath, _todoPath));
  }

  @override
  int get hashCode => Object.hash(runtimeType, fileId, categoryId, todoId,
      const DeepCollectionEquality().hash(_todoPath));

  @override
  String toString() {
    return 'NotesWorkspaceSelection(fileId: $fileId, categoryId: $categoryId, todoId: $todoId, todoPath: $todoPath)';
  }
}

/// @nodoc
abstract mixin class _$NotesWorkspaceSelectionCopyWith<$Res>
    implements $NotesWorkspaceSelectionCopyWith<$Res> {
  factory _$NotesWorkspaceSelectionCopyWith(_NotesWorkspaceSelection value,
          $Res Function(_NotesWorkspaceSelection) _then) =
      __$NotesWorkspaceSelectionCopyWithImpl;
  @override
  @useResult
  $Res call({int? fileId, int? categoryId, int? todoId, List<int> todoPath});
}

/// @nodoc
class __$NotesWorkspaceSelectionCopyWithImpl<$Res>
    implements _$NotesWorkspaceSelectionCopyWith<$Res> {
  __$NotesWorkspaceSelectionCopyWithImpl(this._self, this._then);

  final _NotesWorkspaceSelection _self;
  final $Res Function(_NotesWorkspaceSelection) _then;

  /// Create a copy of NotesWorkspaceSelection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? fileId = freezed,
    Object? categoryId = freezed,
    Object? todoId = freezed,
    Object? todoPath = null,
  }) {
    return _then(_NotesWorkspaceSelection(
      fileId: freezed == fileId
          ? _self.fileId
          : fileId // ignore: cast_nullable_to_non_nullable
              as int?,
      categoryId: freezed == categoryId
          ? _self.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int?,
      todoId: freezed == todoId
          ? _self.todoId
          : todoId // ignore: cast_nullable_to_non_nullable
              as int?,
      todoPath: null == todoPath
          ? _self._todoPath
          : todoPath // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }
}

// dart format on
