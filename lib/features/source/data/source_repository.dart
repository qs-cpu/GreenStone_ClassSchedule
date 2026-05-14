import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/timetable_source.dart';
import '../domain/sync_record.dart';

final sourceRepositoryProvider = Provider<SourceRepository>((ref) {
  return SourceRepository(ApiClient().dio);
});

class SourceRepository {
  final Dio _dio;

  SourceRepository(this._dio);

  Future<List<TimetableSource>> getSources() async {
    try {
      final response = await _dio.get(ApiEndpoints.sources);
      return (response.data as List).map((e) => TimetableSource.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<TimetableSource> getSourceDetail(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.sourceDetail(id));
      return TimetableSource.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<SyncRecord> syncSource(String id) async {
    try {
      final response = await _dio.post(ApiEndpoints.sourceSync(id));
      return SyncRecord.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
