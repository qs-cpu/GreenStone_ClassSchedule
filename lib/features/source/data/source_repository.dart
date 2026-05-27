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
    final data = response.data;
    if (data is! List) {
      throw const FormatException('来源列表响应格式错误');
    }
    return data
        .map(
          (e) => TimetableSource.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  Future<TimetableSource> getSourceDetail(String id) async {
    final response = await _dio.get(ApiEndpoints.sourceDetail(id));
    final data = response.data;
    if (data is! Map) {
      throw const FormatException('来源详情响应格式错误');
    }
    return TimetableSource.fromJson(Map<String, dynamic>.from(data));
  }

  Future<SyncRecord> syncSource(String id) async {
    final response = await _dio.post(ApiEndpoints.sourceSync(id));
    final data = response.data;
    if (data is! Map) {
      throw const FormatException('同步响应格式错误');
    }
    return SyncRecord.fromJson(Map<String, dynamic>.from(data));
  }
}
