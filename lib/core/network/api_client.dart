import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 提供全局的 Dio 实例，替代手写单例模式
final dioProvider = Provider<Dio>((ref) {
  // 从环境变量获取，如果不提供则根据是否为 web 选择默认值
  const defaultUrl = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
  const baseUrl = String.fromEnvironment('API_URL', defaultValue: defaultUrl);

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));

  return dio;
});

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
