// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CourseSession _$CourseSessionFromJson(Map<String, dynamic> json) =>
    _CourseSession(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      weekday: (json['weekday'] as num).toInt(),
      startSection: (json['startSection'] as num).toInt(),
      endSection: (json['endSection'] as num).toInt(),
      startWeek: (json['startWeek'] as num).toInt(),
      endWeek: (json['endWeek'] as num).toInt(),
      weekType: json['weekType'] as String,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CourseSessionToJson(_CourseSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'courseId': instance.courseId,
      'weekday': instance.weekday,
      'startSection': instance.startSection,
      'endSection': instance.endSection,
      'startWeek': instance.startWeek,
      'endWeek': instance.endWeek,
      'weekType': instance.weekType,
      'note': instance.note,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
