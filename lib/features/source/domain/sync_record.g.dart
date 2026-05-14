// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SyncRecord _$SyncRecordFromJson(Map<String, dynamic> json) => _SyncRecord(
  id: json['id'] as String,
  sourceId: json['sourceId'] as String,
  status: json['status'] as String,
  message: json['message'] as String?,
  startedAt: DateTime.parse(json['startedAt'] as String),
  finishedAt: DateTime.parse(json['finishedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SyncRecordToJson(_SyncRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sourceId': instance.sourceId,
      'status': instance.status,
      'message': instance.message,
      'startedAt': instance.startedAt.toIso8601String(),
      'finishedAt': instance.finishedAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
