import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_record.freezed.dart';
part 'sync_record.g.dart';

@freezed
abstract class SyncRecord with _$SyncRecord {
  const factory SyncRecord({
    required String id,
    required String sourceId,
    required String status,
    String? message,
    required DateTime startedAt,
    required DateTime finishedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SyncRecord;

  factory SyncRecord.fromJson(Map<String, dynamic> json) => _$SyncRecordFromJson(json);
}
