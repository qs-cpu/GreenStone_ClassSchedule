import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/timetable.dart';

final timetableRepositoryProvider = Provider<TimetableRepository>((ref) {
  return TimetableRepository(ref.watch(dioProvider));
});

class TimetableRepository {
  final Dio _dio;

  TimetableRepository(this._dio);

  Future<List<Timetable>> getTimetables() async {
    final response = await _dio.get(ApiEndpoints.timetables);
    return (response.data as List).map((e) => Timetable.fromJson(e)).toList();
  }

  Future<Timetable> getTimetableDetail(String id) async {
    final response = await _dio.get(ApiEndpoints.timetableDetail(id));
    return Timetable.fromJson(response.data);
  }

  Future<Map<String, dynamic>> getTimetableWeek(String id, int weekNo) async {
    final response = await _dio.get(ApiEndpoints.timetableWeek(id, weekNo));
    return response.data;
  }
}
