import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<void> register(
    String username,
    String password,
    String? nickname,
  ) async {
    await _dio.post(
      ApiEndpoints.register,
      data: {
        'username': username,
        'password': password,
        if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
      },
    );
  }

  Future<String> login(String username, String password) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {'username': username, 'password': password},
    );
    final data = response.data;
    if (data is Map && data['token'] is String) {
      return data['token'] as String;
    }
    throw const FormatException('登录响应缺少 token');
  }
}
