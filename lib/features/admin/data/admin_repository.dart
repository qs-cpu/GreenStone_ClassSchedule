import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(dioProvider));
});

class AdminRepository {
  final Dio _dio;

  AdminRepository(this._dio);

  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int pageSize = 20,
    String? search,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.adminUsers,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (search != null) 'search': search,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getUserDetail(String id) async {
    final response = await _dio.get(ApiEndpoints.adminUserDetail(id));
    return response.data;
  }

  Future<Map<String, dynamic>> createUser({
    required String username,
    required String password,
    String? nickname,
    String role = 'user',
  }) async {
    final response = await _dio.post(
      ApiEndpoints.adminUsers,
      data: {
        'username': username,
        'password': password,
        if (nickname != null) 'nickname': nickname,
        'role': role,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> updateUser({
    required String id,
    String? nickname,
    String? role,
    String? password,
  }) async {
    final data = <String, dynamic>{};
    if (nickname != null) data['nickname'] = nickname;
    if (role != null) data['role'] = role;
    if (password != null && password.isNotEmpty) data['password'] = password;

    final response = await _dio.put(
      ApiEndpoints.adminUserDetail(id),
      data: data,
    );
    return response.data;
  }

  Future<void> deleteUser(String id) async {
    await _dio.delete(ApiEndpoints.adminUserDetail(id));
  }

  Future<Map<String, dynamic>> getStats() async {
    final response = await _dio.get(ApiEndpoints.adminUserStats);
    return response.data;
  }
}
