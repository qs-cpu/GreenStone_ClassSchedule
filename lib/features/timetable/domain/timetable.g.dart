// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable.dart';

_Timetable _$TimetableFromJson(Map<String, dynamic> json) => _Timetable(
  id: (json['id'] ?? json['userId'] ?? '').toString(),
  userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
  termId: (json['term_id'] ?? json['termId'] ?? '').toString(),
  title: (json['title'] ?? '').toString(),
  sourceId: json['source_id']?.toString() ?? json['sourceId']?.toString(),
  createdAt: _parseDate(json['created_at'] ?? json['createdAt'] ?? ''),
  updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt'] ?? ''),
  courses:
      (json['courses'] as List<dynamic>?)
          ?.map((e) => Course.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$TimetableToJson(_Timetable instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'term_id': instance.termId,
      'title': instance.title,
      'source_id': instance.sourceId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'courses': instance.courses,
    };
