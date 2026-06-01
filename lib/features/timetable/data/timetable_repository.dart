import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import 'timetable_cache_repository.dart';
import '../domain/timetable.dart';

final timetableRepositoryProvider = Provider<TimetableRepository>((ref) {
  return TimetableRepository(
    ref.watch(dioProvider),
    ref.watch(timetableCacheRepositoryProvider),
  );
});

class TimetableRepository {
  final Dio _dio;
  final TimetableCacheRepository _cache;

  TimetableRepository(this._dio, this._cache);

  Future<List<Timetable>> getTimetables() async {
    try {
      final response = await _dio.get(ApiEndpoints.timetables);
      final data = response.data;
      if (data is! List) {
        throw const FormatException('课表列表响应格式错误');
      }
      final timetables = data
          .whereType<Map>()
          .map((e) => Timetable.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      await _cache.cacheTimetables(timetables);
      return timetables;
    } catch (error) {
      if (error is DioException && error.response?.statusCode != null) {
        rethrow;
      }
      final cached = _cache.getTimetables();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<Timetable> getTimetableDetail(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.timetableDetail(id));
      final data = response.data;
      if (data is! Map) {
        throw const FormatException('课表详情响应格式错误');
      }
      final timetable = Timetable.fromJson(Map<String, dynamic>.from(data));
      await _cache.cacheTimetableDetail(timetable);
      await _cache.setSelectedTimetableId(timetable.id);
      return timetable;
    } catch (error) {
      if (error is DioException && error.response?.statusCode != null) {
        rethrow;
      }
      final cached = _cache.getTimetableDetail(id);
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getTimetableWeek(String id, int weekNo) async {
    final response = await _dio.get(ApiEndpoints.timetableWeek(id, weekNo));
    return response.data;
  }
}
