import 'package:freezed_annotation/freezed_annotation.dart';
import 'course_session.dart';

part 'course.freezed.dart';
part 'course.g.dart';

DateTime _parseDate(dynamic v) {
  try {
    return DateTime.parse(v.toString());
  } catch (_) {
    return DateTime.now();
  }
}

@freezed
abstract class Course with _$Course {
  const factory Course({
    required String id,
    required String timetableId,
    required String title,
    String? teacher,
    String? color,
    String? remark,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default([]) List<CourseSession> sessions,
  }) = _Course;

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
}
