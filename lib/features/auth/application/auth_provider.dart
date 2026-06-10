import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

// 用户信息模型
class UserInfo {
  final String id;
  final String username;
  final String? nickname;
  final String role;

  const UserInfo({
    required this.id,
    required this.username,
    this.nickname,
    this.role = 'user',
  });

  bool get isAdmin => role == 'admin';

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'nickname': nickname,
    'role': role,
  };

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
    id: json['id'],
    username: json['username'],
    nickname: json['nickname'],
    role: json['role'] ?? 'user',
  );
}

// 用于同步获取 SharedPreferences 实例的 Provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

final initialTokenProvider = Provider<String?>((ref) => null);

// 管理全局 Token 的 Provider
final tokenProvider = StateNotifierProvider<TokenNotifier, String?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  final initialToken = ref.watch(initialTokenProvider);
  return TokenNotifier(prefs, secureStorage, initialToken);
});

// 管理用户信息的 Provider
final userInfoProvider = StateNotifierProvider<UserInfoNotifier, UserInfo?>((
  ref,
) {
  return UserInfoNotifier(ref);
});

class TokenNotifier extends StateNotifier<String?> {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;
  static const _tokenKey = 'jwt_token';

  TokenNotifier(this._prefs, this._secureStorage, String? initialToken)
    : super(initialToken);

  Future<void> setToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    await _prefs.remove(_tokenKey);
    state = token;
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: _tokenKey);
    await _prefs.remove(_tokenKey);
    state = null;
  }
}

class UserInfoNotifier extends StateNotifier<UserInfo?> {
  final Ref _ref;
  static const _userKey = 'user_info';

  UserInfoNotifier(this._ref) : super(null) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        state = UserInfo.fromJson(jsonDecode(userJson));
      } catch (e) {
        // 忽略解析错误
      }
    }
  }

  Future<void> setUser(UserInfo user) async {
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    state = user;
  }

  Future<void> clearUser() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.remove(_userKey);
    state = null;
  }
}

// 登录/注册状态管理
final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>(
  (ref) {
    return AuthNotifier(ref);
  },
);

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AsyncData(null));

  Future<void> login(String username, String password) async {
    state = const AsyncLoading();
    try {
      final repo = _ref.read(authRepositoryProvider);
      final result = await repo.login(username, password);
      await _ref.read(tokenProvider.notifier).setToken(result['token']);
      await _ref
          .read(userInfoProvider.notifier)
          .setUser(
            UserInfo(
              id: result['user']['id'],
              username: result['user']['username'],
              nickname: result['user']['nickname'],
              role: result['user']['role'] ?? 'user',
            ),
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(_authErrorMessage(e, '登录失败'), st);
    }
  }

  Future<void> register(
    String username,
    String password,
    String? nickname,
  ) async {
    state = const AsyncLoading();
    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.register(username, password, nickname);
      // 注册成功后自动登录
      final result = await repo.login(username, password);
      await _ref.read(tokenProvider.notifier).setToken(result['token']);
      await _ref
          .read(userInfoProvider.notifier)
          .setUser(
            UserInfo(
              id: result['user']['id'],
              username: result['user']['username'],
              nickname: result['user']['nickname'],
              role: result['user']['role'] ?? 'user',
            ),
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(_authErrorMessage(e, '注册失败'), st);
    }
  }

  Future<void> logout() async {
    final userId = _ref.read(userInfoProvider)?.id;
    if (userId != null) {
      final prefs = _ref.read(sharedPreferencesProvider);
      final prefix = 'offline_timetable:$userId:';
      final keys = prefs.getKeys().where((key) => key.startsWith(prefix));
      await Future.wait(keys.map(prefs.remove));
    }
    await _ref.read(tokenProvider.notifier).clearToken();
    await _ref.read(userInfoProvider.notifier).clearUser();
    state = const AsyncData(null);
  }
}
