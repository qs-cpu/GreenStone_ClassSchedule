// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

_Course _$CourseFromJson(Map<String, dynamic> json) => _Course(
  id: (json['id'] ?? '').toString(),
  timetableId: (json['timetable_id'] ?? json['timetableId'] ?? '').toString(),
  title: (json['title'] ?? '').toString(),
  teacher: json['teacher']?.toString(),
  color: json['color']?.toString(),
  remark: json['remark']?.toString(),
  createdAt: _parseDate(json['created_at'] ?? json['createdAt'] ?? ''),
  updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt'] ?? ''),
  sessions:
      (json['sessions'] as List<dynamic>?)
          ?.map((e) => CourseSession.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$CourseToJson(_Course instance) => <String, dynamic>{
  'id': instance.id,
  'timetable_id': instance.timetableId,
  'title': instance.title,
  'teacher': instance.teacher,
  'color': instance.color,
  'remark': instance.remark,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'sessions': instance.sessions,
};
