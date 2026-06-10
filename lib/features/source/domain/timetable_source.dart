import 'package:freezed_annotation/freezed_annotation.dart';
import 'sync_record.dart';

part 'timetable_source.freezed.dart';
part 'timetable_source.g.dart';

DateTime _parseDate(dynamic v) {
  try {
    return DateTime.parse(v.toString());
  } catch (_) {
    return DateTime.now();
  }
}

DateTime? _parseDateOrNull(dynamic v) {
  if (v == null) return null;
  try {
    return DateTime.parse(v.toString());
  } catch (_) {
    return null;
  }
}

@freezed
abstract class TimetableSource with _$TimetableSource {
  const factory TimetableSource({
    required String id,
    required String userId,
    required String originalUrl,
    String? finalUrl,
    required String sourceType, // "ICS", "JSON", "HTML", "UNKNOWN"
    String? importerKey,
    String? lastModified,
    DateTime? lastSyncedAt,
    required String syncStatus, // "idle", "syncing", "success", "failed"
    String? errorMessage,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default([]) List<SyncRecord> syncRecords,
  }) = _TimetableSource;

  factory TimetableSource.fromJson(Map<String, dynamic> json) =>
      _$TimetableSourceFromJson(json);
}
