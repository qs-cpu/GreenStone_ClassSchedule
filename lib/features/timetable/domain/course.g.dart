// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Course _$CourseFromJson(Map<String, dynamic> json) => _Course(
  id: json['id'] as String,
  timetableId: json['timetableId'] as String,
  title: json['title'] as String,
  teacher: json['teacher'] as String,
  color: json['color'] as String?,
  remark: json['remark'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  sessions:
      (json['sessions'] as List<dynamic>?)
          ?.map((e) => CourseSession.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$CourseToJson(_Course instance) => <String, dynamic>{
  'id': instance.id,
  'timetableId': instance.timetableId,
  'title': instance.title,
  'teacher': instance.teacher,
  'color': instance.color,
  'remark': instance.remark,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'sessions': instance.sessions,
};
