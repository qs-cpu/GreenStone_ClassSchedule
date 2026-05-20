import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../timetable/domain/timetable.dart';

final importRepositoryProvider = Provider<ImportRepository>((ref) {
  return ImportRepository(ref.watch(dioProvider));
});

class ImportRepository {
  final Dio _dio;

  ImportRepository(this._dio);

  Future<Timetable> importFromUrl(String url) async {
    final response = await _dio.post(
      ApiEndpoints.importUrl,
      data: {'url': url},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return Timetable.fromJson(data);
    }
    if (data is Map) {
      return Timetable.fromJson(Map<String, dynamic>.from(data));
    }
    throw const FormatException('URL 导入响应格式错误');
  }

  // 获取验证码
  Future<Map<String, dynamic>> getJwcCaptcha(String school) async {
    final response = await _dio.get(ApiEndpoints.jwcCaptcha(school));
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data; // 返回包含 captchaId, captchaImage 的 Map
    }
    throw const FormatException('验证码响应格式错误');
  }

  // 带验证码的教务导入
  Future<Map<String, dynamic>> importFromJwc({
    required String school,
    required String username,
    required String password,
    required int year,
    required String semester,
    required String captchaId,
    required String captcha,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.importJwc,
      data: {
        'school': school,
        'username': username,
        'password': password,
        'year': year,
        'semester': semester,
        'captchaId': captchaId,
        'captcha': captcha,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw const FormatException('教务导入响应格式错误');
  }
}
