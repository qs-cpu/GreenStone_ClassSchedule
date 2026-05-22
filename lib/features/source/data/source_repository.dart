import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/timetable_source.dart';
import '../domain/sync_record.dart';

final sourceRepositoryProvider = Provider<SourceRepository>((ref) {
  return SourceRepository(ref.watch(dioProvider));
});

class SourceRepository {
  final Dio _dio;

  SourceRepository(this._dio);

  Future<List<TimetableSource>> getSources() async {
    final response = await _dio.get(ApiEndpoints.sources);
    return (response.data as List)
        .map((e) => TimetableSource.fromJson(e))
        .toList();
  }

  Future<TimetableSource> getSourceDetail(String id) async {
    final response = await _dio.get(ApiEndpoints.sourceDetail(id));
    return TimetableSource.fromJson(response.data);
  }

  Future<SyncRecord> syncSource(String id) async {
    final response = await _dio.post(ApiEndpoints.sourceSync(id));
    return SyncRecord.fromJson(response.data);
  }
}
