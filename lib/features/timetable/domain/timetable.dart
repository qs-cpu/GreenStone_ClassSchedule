import 'package:freezed_annotation/freezed_annotation.dart';
import 'course.dart';

part 'timetable.freezed.dart';
part 'timetable.g.dart';

@freezed
abstract class Timetable with _$Timetable {
  const factory Timetable({
    required String id,
    required String userId,
    required String termId,
    required String title,
    String? sourceId,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default([]) List<Course> courses,
  }) = _Timetable;

  factory Timetable.fromJson(Map<String, dynamic> json) => _$TimetableFromJson(json);
}
