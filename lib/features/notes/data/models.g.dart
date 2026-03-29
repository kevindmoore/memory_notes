// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TodoFile _$TodoFileFromJson(Map<String, dynamic> json) => _TodoFile(
      name: json['name'] as String,
      id: (json['id'] as num?)?.toInt(),
      userId: json['user_id'] as String?,
      lastUpdated: json['last_updated'] == null
          ? null
          : DateTime.parse(json['last_updated'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$TodoFileToJson(_TodoFile instance) => <String, dynamic>{
      'name': instance.name,
      if (instance.id case final value?) 'id': value,
      if (instance.userId case final value?) 'user_id': value,
      if (instance.lastUpdated?.toIso8601String() case final value?)
        'last_updated': value,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
    };

_Category _$CategoryFromJson(Map<String, dynamic> json) => _Category(
      name: json['name'] as String,
      id: (json['id'] as num?)?.toInt(),
      todoFileId: (json['todoFileId'] as num?)?.toInt(),
      userId: json['user_id'] as String?,
      lastUpdated: json['last_updated'] == null
          ? null
          : DateTime.parse(json['last_updated'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$CategoryToJson(_Category instance) => <String, dynamic>{
      'name': instance.name,
      if (instance.id case final value?) 'id': value,
      if (instance.todoFileId case final value?) 'todoFileId': value,
      if (instance.userId case final value?) 'user_id': value,
      if (instance.lastUpdated?.toIso8601String() case final value?)
        'last_updated': value,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
    };

_Todo _$TodoFromJson(Map<String, dynamic> json) => _Todo(
      done: json['done'] as bool? ?? false,
      visible: json['visible'] as bool? ?? true,
      expanded: json['expanded'] as bool? ?? false,
      order: (json['order'] as num?)?.toInt() ?? 0,
      name: json['name'] as String,
      id: (json['id'] as num?)?.toInt(),
      userId: json['user_id'] as String?,
      todoFileId: (json['todoFileId'] as num?)?.toInt(),
      categoryId: (json['categoryId'] as num?)?.toInt(),
      parentTodoId: (json['parentTodoId'] as num?)?.toInt(),
      notes: json['notes'] as String? ?? '',
      lastUpdated: json['last_updated'] == null
          ? null
          : DateTime.parse(json['last_updated'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$TodoToJson(_Todo instance) => <String, dynamic>{
      'done': instance.done,
      'visible': instance.visible,
      'expanded': instance.expanded,
      'order': instance.order,
      'name': instance.name,
      if (instance.id case final value?) 'id': value,
      if (instance.userId case final value?) 'user_id': value,
      if (instance.todoFileId case final value?) 'todoFileId': value,
      if (instance.categoryId case final value?) 'categoryId': value,
      if (instance.parentTodoId case final value?) 'parentTodoId': value,
      'notes': instance.notes,
      if (instance.lastUpdated?.toIso8601String() case final value?)
        'last_updated': value,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
    };

_CurrentState _$CurrentStateFromJson(Map<String, dynamic> json) =>
    _CurrentState(
      currentFiles: json['currentFiles'] as String,
      id: (json['id'] as num?)?.toInt(),
      userId: json['user_id'] as String?,
      lastUpdated: json['last_updated'] == null
          ? null
          : DateTime.parse(json['last_updated'] as String),
    );

Map<String, dynamic> _$CurrentStateToJson(_CurrentState instance) =>
    <String, dynamic>{
      'currentFiles': instance.currentFiles,
      if (instance.id case final value?) 'id': value,
      if (instance.userId case final value?) 'user_id': value,
      if (instance.lastUpdated?.toIso8601String() case final value?)
        'last_updated': value,
    };
