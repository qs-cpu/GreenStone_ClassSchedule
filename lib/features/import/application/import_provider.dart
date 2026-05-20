import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../data/import_repository.dart';
import '../../timetable/application/timetable_provider.dart';

String _dioErrorMessage(Object error, String fallback) {
  if (error is! DioException) return fallback;

  final data = error.response?.data;
  if (data is Map && data['error'] != null) {
    return data['error'].toString();
  }
  if (data is String && data.trim().isNotEmpty) {
    return data;
  }
  return error.message ?? fallback;
}

final importStateProvider =
    StateNotifierProvider<ImportNotifier, AsyncValue<void>>((ref) {
      return ImportNotifier(ref);
    });

class ImportNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  ImportNotifier(this._ref) : super(const AsyncData(null));

  Future<void> importFromUrl(String url) async {
    state = const AsyncLoading();
    try {
      final repository = _ref.read(importRepositoryProvider);
      final timetable = await repository.importFromUrl(url);
      _ref.read(selectedTimetableIdProvider.notifier).state = timetable.id;
      _ref.invalidate(timetablesProvider);
      _ref.invalidate(currentTimetableDetailProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(_dioErrorMessage(e, '导入失败'), st);
    }
  }

  Future<void> importFromJwc({
    required String school,
    required String username,
    required String password,
    required int year,
    required String semester,
    required String captchaId,
    required String captcha,
  }) async {
    state = const AsyncLoading();
    try {
      final repository = _ref.read(importRepositoryProvider);
      final data = await repository.importFromJwc(
        school: school,
        username: username,
        password: password,
        year: year,
        semester: semester,
        captchaId: captchaId,
        captcha: captcha,
      );
      final timetable = data['timetable'];
      if (timetable is Map<String, dynamic> && timetable['id'] is String) {
        _ref.read(selectedTimetableIdProvider.notifier).state =
            timetable['id'] as String;
      } else {
        throw const FormatException('导入成功但服务端未返回有效课表 ID');
      }
      _ref.invalidate(timetablesProvider);
      _ref.invalidate(currentTimetableDetailProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(_dioErrorMessage(e, '教务系统登录失败或导入失败'), st);
    }
  }
}

// ---- 验证码状态管理 ----
class CaptchaState {
  final String? captchaId;
  final String? captchaImage;
  final bool isLoading;
  final String? error;

  CaptchaState({
    this.captchaId,
    this.captchaImage,
    this.isLoading = false,
    this.error,
  });
}

final captchaProvider = StateNotifierProvider<CaptchaNotifier, CaptchaState>((
  ref,
) {
  return CaptchaNotifier(ref);
});

class CaptchaNotifier extends StateNotifier<CaptchaState> {
  final Ref _ref;

  CaptchaNotifier(this._ref) : super(CaptchaState());

  Future<void> fetchCaptcha(String school) async {
    state = CaptchaState(isLoading: true);
    try {
      final repo = _ref.read(importRepositoryProvider);
      final data = await repo.getJwcCaptcha(school);
      state = CaptchaState(
        captchaId: data['captchaId'],
        captchaImage: data['captchaImage'],
        isLoading: false,
      );
    } catch (e) {
      state = CaptchaState(error: '获取验证码失败', isLoading: false);
    }
  }
}
