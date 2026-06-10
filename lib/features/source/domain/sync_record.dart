import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_record.freezed.dart';
part 'sync_record.g.dart';

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
abstract class SyncRecord with _$SyncRecord {
  const factory SyncRecord({
    required String id,
    required String sourceId,
    required String status,
    String? message,
    required DateTime startedAt,
    DateTime? finishedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SyncRecord;

  factory SyncRecord.fromJson(Map<String, dynamic> json) =>
      _$SyncRecordFromJson(json);
}
