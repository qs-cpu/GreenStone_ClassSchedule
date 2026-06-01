import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/application/auth_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  // 修改后端端口默认值为 3001 以适配最新 API 文档
  const defaultUrl = kIsWeb ? 'http://localhost:3001' : 'http://10.0.2.2:3001';
  const baseUrl = String.fromEnvironment('API_URL', defaultValue: defaultUrl);
  const allowInsecureApi = bool.fromEnvironment(
    'ALLOW_INSECURE_API',
    defaultValue: kDebugMode,
  );

  if (!allowInsecureApi && baseUrl.startsWith('http://')) {
    throw StateError(
      'Release API_URL must use HTTPS, or explicitly set ALLOW_INSECURE_API=true for trusted testing.',
    );
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
    ),
  );

  // 认证拦截器：自动注入 Bearer Token
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = ref.read(tokenProvider);
        if (token != null && !options.path.startsWith('/api/auth/')) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // 收到 401 自动清空本地 token (踢出登录)
        if (e.response?.statusCode == 401 &&
            !e.requestOptions.path.startsWith('/api/auth/')) {
          ref.read(tokenProvider.notifier).clearToken();
        }
        return handler.next(e);
      },
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        requestHeader: false,
        responseHeader: false,
      ),
    );
  }

  return dio;
});

class ApiEndpoints {
  // 认证相关
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';

  // 导入相关
  static const String importUrl = '/api/import';
  static const String importJwc = '/api/import-jwc';
  static String jwcCaptcha(String school) =>
      '/api/import-jwc/captcha?school=${Uri.encodeQueryComponent(school)}';

  // 课表相关
  static const String timetables = '/api/timetables';
  static String timetableDetail(String id) => '/api/timetables/$id';
  static String timetableWeek(String id, int weekNo) =>
      '/api/timetables/$id/week/$weekNo';
  static String timetableDay(String id) => '/api/timetables/$id/day';

  // 来源相关
  static const String sources = '/api/sources';
  static String sourceDetail(String id) => '/api/sources/$id';
  static String sourceSync(String id) => '/api/sources/$id/sync';

  // 管理员相关
  static const String adminUsers = '/api/admin/users';
  static String adminUserDetail(String id) => '/api/admin/users/$id';
  static const String adminUserStats = '/api/admin/users/stats/overview';
}
