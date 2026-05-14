import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../timetable/domain/timetable.dart';

final importRepositoryProvider = Provider<ImportRepository>((ref) {
  return ImportRepository(ApiClient().dio);
});

class ImportRepository {
  final Dio _dio;

  ImportRepository(this._dio);

  Future<Timetable> importFromUrl(String url) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.importUrl,
        data: {'url': url},
      );
      return Timetable.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> importFromJwc({
    required String school,
    required String username,
    required String password,
    required int year,
    required String semester,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.importJwc,
        data: {
          'school': school,
          'username': username,
          'password': password,
          'year': year,
          'semester': semester,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
