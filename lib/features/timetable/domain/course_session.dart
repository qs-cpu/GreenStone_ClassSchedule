import 'package:freezed_annotation/freezed_annotation.dart';

part 'course_session.freezed.dart';
part 'course_session.g.dart';

DateTime _parseDate(dynamic v) {
  try {
    return DateTime.parse(v.toString());
  } catch (_) {
    return DateTime.now();
  }
}

@freezed
abstract class CourseSession with _$CourseSession {
  const factory CourseSession({
    required String id,
    required String courseId,
    required int weekday,
    required int startSection,
    required int endSection,
    required int startWeek,
    required int endWeek,
    required String weekType, // "all", "odd", "even"
    String? location,
    String? note,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CourseSession;

  factory CourseSession.fromJson(Map<String, dynamic> json) =>
      _$CourseSessionFromJson(json);
}
