import 'package:dio/dio.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        // 请根据实际环境调整 baseURL
        // Windows/Mac 本地跑 Android 模拟器时 localhost 可能是 10.0.2.2 
        // WSL 中的端口如果做了映射也是 localhost
        baseUrl: 'http://localhost:3000',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        responseType: ResponseType.json,
      ),
    );

    // 添加日志拦截器等
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));

    // 错误处理拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) {
          // 这里可以进行全局的错误拦截与提示转换
          return handler.next(e);
        },
      ),
    );
  }
}

// 核心 API 路径常量
class ApiEndpoints {
  static const String importUrl = '/api/import';
  static const String importJwc = '/api/import-jwc';
  
  static const String timetables = '/api/timetables';
  static String timetableDetail(String id) => '/api/timetables/$id';
  static String timetableWeek(String id, int weekNo) => '/api/timetables/$id/week/$weekNo';
  static String timetableDay(String id) => '/api/timetables/$id/day';

  static const String sources = '/api/sources';
  static String sourceDetail(String id) => '/api/sources/$id';
  static String sourceSync(String id) => '/api/sources/$id/sync';
}
