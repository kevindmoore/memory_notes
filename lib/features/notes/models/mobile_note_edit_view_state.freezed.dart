// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mobile_note_edit_view_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MobileNoteEditViewState {
  String get fileName;
  Category? get category;
  Todo? get parentTodo;
  Todo? get focusedTodo;
  String get screenTitle;
  List<Todo> get allTodos;
  List<Todo> get visibleTodos;

  /// Create a copy of MobileNoteEditViewState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MobileNoteEditViewStateCopyWith<MobileNoteEditViewState> get copyWith =>
      _$MobileNoteEditViewStateCopyWithImpl<MobileNoteEditViewState>(
          this as MobileNoteEditViewState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MobileNoteEditViewState &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.parentTodo, parentTodo) ||
                other.parentTodo == parentTodo) &&
            (identical(other.focusedTodo, focusedTodo) ||
                other.focusedTodo == focusedTodo) &&
            (identical(other.screenTitle, screenTitle) ||
                other.screenTitle == screenTitle) &&
            const DeepCollectionEquality().equals(other.allTodos, allTodos) &&
            const DeepCollectionEquality()
                .equals(other.visibleTodos, visibleTodos));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      fileName,
      category,
      parentTodo,
      focusedTodo,
      screenTitle,
      const DeepCollectionEquality().hash(allTodos),
      const DeepCollectionEquality().hash(visibleTodos));

  @override
  String toString() {
    return 'MobileNoteEditViewState(fileName: $fileName, category: $category, parentTodo: $parentTodo, focusedTodo: $focusedTodo, screenTitle: $screenTitle, allTodos: $allTodos, visibleTodos: $visibleTodos)';
  }
}

/// @nodoc
abstract mixin class $MobileNoteEditViewStateCopyWith<$Res> {
  factory $MobileNoteEditViewStateCopyWith(MobileNoteEditViewState value,
          $Res Function(MobileNoteEditViewState) _then) =
      _$MobileNoteEditViewStateCopyWithImpl;
  @useResult
  $Res call(
      {String fileName,
      Category? category,
      Todo? parentTodo,
      Todo? focusedTodo,
      String screenTitle,
      List<Todo> allTodos,
      List<Todo> visibleTodos});

  $CategoryCopyWith<$Res>? get category;
  $TodoCopyWith<$Res>? get parentTodo;
  $TodoCopyWith<$Res>? get focusedTodo;
}

/// @nodoc
class _$MobileNoteEditViewStateCopyWithImpl<$Res>
    implements $MobileNoteEditViewStateCopyWith<$Res> {
  _$MobileNoteEditViewStateCopyWithImpl(this._self, this._then);

  final MobileNoteEditViewState _self;
  final $Res Function(MobileNoteEditViewState) _then;

  /// Create a copy of MobileNoteEditViewState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileName = null,
    Object? category = freezed,
    Object? parentTodo = freezed,
    Object? focusedTodo = freezed,
    Object? screenTitle = null,
    Object? allTodos = null,
    Object? visibleTodos = null,
  }) {
    return _then(_self.copyWith(
      fileName: null == fileName
          ? _self.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      category: freezed == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as Category?,
      parentTodo: freezed == parentTodo
          ? _self.parentTodo
          : parentTodo // ignore: cast_nullable_to_non_nullable
              as Todo?,
      focusedTodo: freezed == focusedTodo
          ? _self.focusedTodo
          : focusedTodo // ignore: cast_nullable_to_non_nullable
              as Todo?,
      screenTitle: null == screenTitle
          ? _self.screenTitle
          : screenTitle // ignore: cast_nullable_to_non_nullable
              as String,
      allTodos: null == allTodos
          ? _self.allTodos
          : allTodos // ignore: cast_nullable_to_non_nullable
              as List<Todo>,
      visibleTodos: null == visibleTodos
          ? _self.visibleTodos
          : visibleTodos // ignore: cast_nullable_to_non_nullable
              as List<Todo>,
    ));
  }

  /// Create a copy of MobileNoteEditViewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CategoryCopyWith<$Res>? get category {
    if (_self.category == null) {
      return null;
    }

    return $CategoryCopyWith<$Res>(_self.category!, (value) {
      return _then(_self.copyWith(category: value));
    });
  }

  /// Create a copy of MobileNoteEditViewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TodoCopyWith<$Res>? get parentTodo {
    if (_self.parentTodo == null) {
      return null;
    }

    return $TodoCopyWith<$Res>(_self.parentTodo!, (value) {
      return _then(_self.copyWith(parentTodo: value));
    });
  }

  /// Create a copy of MobileNoteEditViewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TodoCopyWith<$Res>? get focusedTodo {
    if (_self.focusedTodo == null) {
      return null;
    }

    return $TodoCopyWith<$Res>(_self.focusedTodo!, (value) {
      return _then(_self.copyWith(focusedTodo: value));
    });
  }
}

/// Adds pattern-matching-related methods to [MobileNoteEditViewState].
extension MobileNoteEditViewStatePatterns on MobileNoteEditViewState {
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
    TResult Function(_MobileNoteEditViewState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MobileNoteEditViewState() when $default != null:
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
    TResult Function(_MobileNoteEditViewState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MobileNoteEditViewState():
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
    TResult? Function(_MobileNoteEditViewState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MobileNoteEditViewState() when $default != null:
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
            String fileName,
            Category? category,
            Todo? parentTodo,
            Todo? focusedTodo,
            String screenTitle,
            List<Todo> allTodos,
            List<Todo> visibleTodos)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MobileNoteEditViewState() when $default != null:
        return $default(
            _that.fileName,
            _that.category,
            _that.parentTodo,
            _that.focusedTodo,
            _that.screenTitle,
            _that.allTodos,
            _that.visibleTodos);
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
            String fileName,
            Category? category,
            Todo? parentTodo,
            Todo? focusedTodo,
            String screenTitle,
            List<Todo> allTodos,
            List<Todo> visibleTodos)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MobileNoteEditViewState():
        return $default(
            _that.fileName,
            _that.category,
            _that.parentTodo,
            _that.focusedTodo,
            _that.screenTitle,
            _that.allTodos,
            _that.visibleTodos);
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
            String fileName,
            Category? category,
            Todo? parentTodo,
            Todo? focusedTodo,
            String screenTitle,
            List<Todo> allTodos,
            List<Todo> visibleTodos)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MobileNoteEditViewState() when $default != null:
        return $default(
            _that.fileName,
            _that.category,
            _that.parentTodo,
            _that.focusedTodo,
            _that.screenTitle,
            _that.allTodos,
            _that.visibleTodos);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _MobileNoteEditViewState implements MobileNoteEditViewState {
  const _MobileNoteEditViewState(
      {required this.fileName,
      this.category,
      this.parentTodo,
      this.focusedTodo,
      required this.screenTitle,
      final List<Todo> allTodos = const <Todo>[],
      final List<Todo> visibleTodos = const <Todo>[]})
      : _allTodos = allTodos,
        _visibleTodos = visibleTodos;

  @override
  final String fileName;
  @override
  final Category? category;
  @override
  final Todo? parentTodo;
  @override
  final Todo? focusedTodo;
  @override
  final String screenTitle;
  final List<Todo> _allTodos;
  @override
  @JsonKey()
  List<Todo> get allTodos {
    if (_allTodos is EqualUnmodifiableListView) return _allTodos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allTodos);
  }

  final List<Todo> _visibleTodos;
  @override
  @JsonKey()
  List<Todo> get visibleTodos {
    if (_visibleTodos is EqualUnmodifiableListView) return _visibleTodos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_visibleTodos);
  }

  /// Create a copy of MobileNoteEditViewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MobileNoteEditViewStateCopyWith<_MobileNoteEditViewState> get copyWith =>
      __$MobileNoteEditViewStateCopyWithImpl<_MobileNoteEditViewState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MobileNoteEditViewState &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.parentTodo, parentTodo) ||
                other.parentTodo == parentTodo) &&
            (identical(other.focusedTodo, focusedTodo) ||
                other.focusedTodo == focusedTodo) &&
            (identical(other.screenTitle, screenTitle) ||
                other.screenTitle == screenTitle) &&
            const DeepCollectionEquality().equals(other._allTodos, _allTodos) &&
            const DeepCollectionEquality()
                .equals(other._visibleTodos, _visibleTodos));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      fileName,
      category,
      parentTodo,
      focusedTodo,
      screenTitle,
      const DeepCollectionEquality().hash(_allTodos),
      const DeepCollectionEquality().hash(_visibleTodos));

  @override
  String toString() {
    return 'MobileNoteEditViewState(fileName: $fileName, category: $category, parentTodo: $parentTodo, focusedTodo: $focusedTodo, screenTitle: $screenTitle, allTodos: $allTodos, visibleTodos: $visibleTodos)';
  }
}

/// @nodoc
abstract mixin class _$MobileNoteEditViewStateCopyWith<$Res>
    implements $MobileNoteEditViewStateCopyWith<$Res> {
  factory _$MobileNoteEditViewStateCopyWith(_MobileNoteEditViewState value,
          $Res Function(_MobileNoteEditViewState) _then) =
      __$MobileNoteEditViewStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String fileName,
      Category? category,
      Todo? parentTodo,
      Todo? focusedTodo,
      String screenTitle,
      List<Todo> allTodos,
      List<Todo> visibleTodos});

  @override
  $CategoryCopyWith<$Res>? get category;
  @override
  $TodoCopyWith<$Res>? get parentTodo;
  @override
  $TodoCopyWith<$Res>? get focusedTodo;
}

/// @nodoc
class __$MobileNoteEditViewStateCopyWithImpl<$Res>
    implements _$MobileNoteEditViewStateCopyWith<$Res> {
  __$MobileNoteEditViewStateCopyWithImpl(this._self, this._then);

  final _MobileNoteEditViewState _self;
  final $Res Function(_MobileNoteEditViewState) _then;

  /// Create a copy of MobileNoteEditViewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? fileName = null,
    Object? category = freezed,
    Object? parentTodo = freezed,
    Object? focusedTodo = freezed,
    Object? screenTitle = null,
    Object? allTodos = null,
    Object? visibleTodos = null,
  }) {
    return _then(_MobileNoteEditViewState(
      fileName: null == fileName
          ? _self.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      category: freezed == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as Category?,
      parentTodo: freezed == parentTodo
          ? _self.parentTodo
          : parentTodo // ignore: cast_nullable_to_non_nullable
              as Todo?,
      focusedTodo: freezed == focusedTodo
          ? _self.focusedTodo
          : focusedTodo // ignore: cast_nullable_to_non_nullable
              as Todo?,
      screenTitle: null == screenTitle
          ? _self.screenTitle
          : screenTitle // ignore: cast_nullable_to_non_nullable
              as String,
      allTodos: null == allTodos
          ? _self._allTodos
          : allTodos // ignore: cast_nullable_to_non_nullable
              as List<Todo>,
      visibleTodos: null == visibleTodos
          ? _self._visibleTodos
          : visibleTodos // ignore: cast_nullable_to_non_nullable
              as List<Todo>,
    ));
  }

  /// Create a copy of MobileNoteEditViewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CategoryCopyWith<$Res>? get category {
    if (_self.category == null) {
      return null;
    }

    return $CategoryCopyWith<$Res>(_self.category!, (value) {
      return _then(_self.copyWith(category: value));
    });
  }

  /// Create a copy of MobileNoteEditViewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TodoCopyWith<$Res>? get parentTodo {
    if (_self.parentTodo == null) {
      return null;
    }

    return $TodoCopyWith<$Res>(_self.parentTodo!, (value) {
      return _then(_self.copyWith(parentTodo: value));
    });
  }

  /// Create a copy of MobileNoteEditViewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TodoCopyWith<$Res>? get focusedTodo {
    if (_self.focusedTodo == null) {
      return null;
    }

    return $TodoCopyWith<$Res>(_self.focusedTodo!, (value) {
      return _then(_self.copyWith(focusedTodo: value));
    });
  }
}

// dart format on
