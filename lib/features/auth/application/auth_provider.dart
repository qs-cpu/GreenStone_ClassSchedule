import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/auth_repository.dart';
import 'package:dio/dio.dart';

String _authErrorMessage(Object error, String fallback) {
  if (error is! DioException) return fallback;

  if (error.response?.statusCode == 401) {
    return '用户名或密码错误';
  }

  final data = error.response?.data;
  if (data is Map && data['error'] != null) {
    return data['error'].toString();
  }
  if (data is String && data.trim().isNotEmpty) {
    return data;
  }
  return error.message ?? fallback;
}

// 用于同步获取 SharedPreferences 实例的 Provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

// 管理全局 Token 的 Provider
final tokenProvider = StateNotifierProvider<TokenNotifier, String?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TokenNotifier(prefs);
});

class TokenNotifier extends StateNotifier<String?> {
  final SharedPreferences _prefs;
  static const _tokenKey = 'jwt_token';

  TokenNotifier(this._prefs) : super(_prefs.getString(_tokenKey));

  Future<void> setToken(String token) async {
    await _prefs.setString(_tokenKey, token);
    state = token;
  }

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
    state = null;
  }
}

// 登录/注册状态管理
final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AsyncData(null));

  Future<void> login(String username, String password) async {
    state = const AsyncLoading();
    try {
      final repo = _ref.read(authRepositoryProvider);
      final token = await repo.login(username, password);
      await _ref.read(tokenProvider.notifier).setToken(token);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(_authErrorMessage(e, '登录失败'), st);
    }
  }

  Future<void> register(String username, String password, String? nickname) async {
    state = const AsyncLoading();
    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.register(username, password, nickname);
      // 注册成功后自动登录
      await login(username, password);
    } catch (e, st) {
      state = AsyncError(_authErrorMessage(e, '注册失败'), st);
    }
  }

  Future<void> logout() async {
    await _ref.read(tokenProvider.notifier).clearToken();
  }
}
