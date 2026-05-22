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
    try {
      await _dio.post(
        ApiEndpoints.register,
        data: {
          'username': username,
          'password': password,
          if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<String> login(String username, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'username': username, 'password': password},
      );
      return response.data['token'] as String;
    } catch (e) {
      rethrow;
    }
  }
}
