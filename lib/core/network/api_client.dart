import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/application/auth_provider.dart';

String _defaultBaseUrl() {
  // --dart-define=API_URL=... overrides everything
  const envUrl = String.fromEnvironment('API_URL');
  if (envUrl.isNotEmpty) return envUrl;

  if (kIsWeb) {
    // Use same host as the current page, port 3001.
    // This works whether you access via localhost, 192.168.x.x, or a domain.
    final host = Uri.base.host;
    return 'http://$host:3001';
  }

  // Android emulator → host machine's localhost
  return 'http://10.0.2.2:3001';
}

final dioProvider = Provider<Dio>((ref) {
  final baseUrl = _defaultBaseUrl();
  const allowInsecureApi = bool.fromEnvironment(
    'ALLOW_INSECURE_API',
    defaultValue: kDebugMode,
  );

  if (!allowInsecureApi && baseUrl.startsWith('http://')) {
    throw StateError(
      'Release API_URL must use HTTPS, or set ALLOW_INSECURE_API=true.',
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
        if (e.response?.statusCode == 401 &&
            !e.requestOptions.path.startsWith('/api/auth/')) {
          ref.read(tokenProvider.notifier).clearToken();
        }
        return handler.next(e);
      },
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      requestHeader: false,
      responseHeader: false,
    ));
  }

  return dio;
});

class ApiEndpoints {
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String importUrl = '/api/import';
  static const String importJwc = '/api/import-jwc';
  static String jwcCaptcha(String school) =>
      '/api/import-jwc/captcha?school=${Uri.encodeQueryComponent(school)}';
  static const String timetables = '/api/timetables';
  static String timetableDetail(String id) => '/api/timetables/$id';
  static String timetableWeek(String id, int weekNo) =>
      '/api/timetables/$id/week/$weekNo';
  static String timetableDay(String id) => '/api/timetables/$id/day';
  static const String sources = '/api/sources';
  static String sourceDetail(String id) => '/api/sources/$id';
  static String sourceSync(String id) => '/api/sources/$id/sync';
  static const String adminUsers = '/api/admin/users';
  static String adminUserDetail(String id) => '/api/admin/users/$id';
  static const String adminUserStats = '/api/admin/users/stats/overview';
}
