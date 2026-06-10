// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_source.dart';

_TimetableSource _$TimetableSourceFromJson(Map<String, dynamic> json) =>
    _TimetableSource(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      originalUrl: (json['original_url'] ?? json['originalUrl'] ?? '').toString(),
      finalUrl: json['final_url']?.toString() ?? json['finalUrl']?.toString(),
      sourceType: (json['source_type'] ?? json['sourceType'] ?? 'UNKNOWN').toString(),
      importerKey: json['importer_key']?.toString() ?? json['importerKey']?.toString(),
      lastModified: json['last_modified']?.toString() ?? json['lastModified']?.toString(),
      lastSyncedAt: _parseDateOrNull(json['last_synced_at'] ?? json['lastSyncedAt']),
      syncStatus: (json['sync_status'] ?? json['syncStatus'] ?? 'idle').toString(),
      errorMessage: json['error_message']?.toString() ?? json['errorMessage']?.toString(),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt'] ?? ''),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt'] ?? ''),
      syncRecords:
          (json['sync_records'] as List<dynamic>?)
              ?.map((e) => SyncRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TimetableSourceToJson(_TimetableSource instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'original_url': instance.originalUrl,
      'final_url': instance.finalUrl,
      'source_type': instance.sourceType,
      'importer_key': instance.importerKey,
      'last_modified': instance.lastModified,
      'last_synced_at': instance.lastSyncedAt?.toIso8601String(),
      'sync_status': instance.syncStatus,
      'error_message': instance.errorMessage,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'sync_records': instance.syncRecords,
    };
