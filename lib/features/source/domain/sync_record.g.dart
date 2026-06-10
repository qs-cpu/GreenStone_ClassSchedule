// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_record.dart';

_SyncRecord _$SyncRecordFromJson(Map<String, dynamic> json) => _SyncRecord(
  id: (json['id'] ?? '').toString(),
  sourceId: (json['source_id'] ?? json['sourceId'] ?? '').toString(),
  status: (json['status'] ?? '').toString(),
  message: json['message']?.toString(),
  startedAt: _parseDate(json['started_at'] ?? json['startedAt'] ?? ''),
  finishedAt: _parseDateOrNull(json['finished_at'] ?? json['finishedAt']),
  createdAt: _parseDate(json['created_at'] ?? json['createdAt'] ?? ''),
  updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt'] ?? ''),
);

Map<String, dynamic> _$SyncRecordToJson(_SyncRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'source_id': instance.sourceId,
      'status': instance.status,
      'message': instance.message,
      'started_at': instance.startedAt.toIso8601String(),
      'finished_at': instance.finishedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
