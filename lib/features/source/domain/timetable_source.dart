import 'package:freezed_annotation/freezed_annotation.dart';
import 'sync_record.dart';

part 'timetable_source.freezed.dart';
part 'timetable_source.g.dart';

@freezed
abstract class TimetableSource with _$TimetableSource {
  const factory TimetableSource({
    required String id,
    required String userId,
    required String originalUrl,
    String? finalUrl,
    required String sourceType, // "ICS", "JSON", "HTML", "UNKNOWN"
    String? importerKey,
    String? etag,
    DateTime? lastModified,
    DateTime? lastSyncedAt,
    required String syncStatus, // "idle", "syncing", "success", "failed"
    String? errorMessage,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default([]) List<SyncRecord> syncRecords,
  }) = _TimetableSource;

  factory TimetableSource.fromJson(Map<String, dynamic> json) => _$TimetableSourceFromJson(json);
}
