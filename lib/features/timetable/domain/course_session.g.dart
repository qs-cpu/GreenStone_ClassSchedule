// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_session.dart';

_CourseSession _$CourseSessionFromJson(Map<String, dynamic> json) =>
    _CourseSession(
      id: (json['id'] ?? '').toString(),
      courseId: (json['course_id'] ?? json['courseId'] ?? '').toString(),
      weekday: int.tryParse((json['weekday'] ?? '').toString()) ?? 1,
      startSection: int.tryParse((json['start_section'] ?? json['startSection'] ?? '').toString()) ?? 1,
      endSection: int.tryParse((json['end_section'] ?? json['endSection'] ?? '').toString()) ?? 2,
      startWeek: int.tryParse((json['start_week'] ?? json['startWeek'] ?? '').toString()) ?? 1,
      endWeek: int.tryParse((json['end_week'] ?? json['endWeek'] ?? '').toString()) ?? 20,
      weekType: (json['week_type'] ?? json['weekType'] ?? 'all').toString(),
      location: json['location']?.toString(),
      note: json['note']?.toString(),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt'] ?? ''),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt'] ?? ''),
    );

Map<String, dynamic> _$CourseSessionToJson(_CourseSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'course_id': instance.courseId,
      'weekday': instance.weekday,
      'start_section': instance.startSection,
      'end_section': instance.endSection,
      'start_week': instance.startWeek,
      'end_week': instance.endWeek,
      'week_type': instance.weekType,
      'location': instance.location,
      'note': instance.note,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
