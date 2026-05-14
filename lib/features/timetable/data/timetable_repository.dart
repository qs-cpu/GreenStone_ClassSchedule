import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/timetable.dart';

final timetableRepositoryProvider = Provider<TimetableRepository>((ref) {
  return TimetableRepository(ApiClient().dio);
});

class TimetableRepository {
  final Dio _dio;

  TimetableRepository(this._dio);

  Future<List<Timetable>> getTimetables() async {
    try {
      final response = await _dio.get(ApiEndpoints.timetables);
      return (response.data as List).map((e) => Timetable.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Timetable> getTimetableDetail(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.timetableDetail(id));
      return Timetable.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // 针对某一特定周的数据拉取
  Future<Map<String, dynamic>> getTimetableWeek(String id, int weekNo) async {
    try {
      final response = await _dio.get(ApiEndpoints.timetableWeek(id, weekNo));
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
