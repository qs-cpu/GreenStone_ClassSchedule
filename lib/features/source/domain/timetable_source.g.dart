// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_source.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TimetableSource _$TimetableSourceFromJson(Map<String, dynamic> json) =>
    _TimetableSource(
      id: json['id'] as String,
      userId: json['userId'] as String,
      originalUrl: json['originalUrl'] as String,
      finalUrl: json['finalUrl'] as String?,
      sourceType: json['sourceType'] as String,
      importerKey: json['importerKey'] as String?,
      etag: json['etag'] as String?,
      lastModified: json['lastModified'] == null
          ? null
          : DateTime.parse(json['lastModified'] as String),
      lastSyncedAt: json['lastSyncedAt'] == null
          ? null
          : DateTime.parse(json['lastSyncedAt'] as String),
      syncStatus: json['syncStatus'] as String,
      errorMessage: json['errorMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      syncRecords:
          (json['syncRecords'] as List<dynamic>?)
              ?.map((e) => SyncRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TimetableSourceToJson(_TimetableSource instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'originalUrl': instance.originalUrl,
      'finalUrl': instance.finalUrl,
      'sourceType': instance.sourceType,
      'importerKey': instance.importerKey,
      'etag': instance.etag,
      'lastModified': instance.lastModified?.toIso8601String(),
      'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
      'syncStatus': instance.syncStatus,
      'errorMessage': instance.errorMessage,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'syncRecords': instance.syncRecords,
    };
