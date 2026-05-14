import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../data/import_repository.dart';

final importStateProvider = StateNotifierProvider<ImportNotifier, AsyncValue<void>>((ref) {
  return ImportNotifier(ref.read(importRepositoryProvider));
});

class ImportNotifier extends StateNotifier<AsyncValue<void>> {
  final ImportRepository _repository;

  ImportNotifier(this._repository) : super(const AsyncData(null));

  Future<void> importFromUrl(String url) async {
    state = const AsyncLoading();
    try {
      await _repository.importFromUrl(url);
      state = const AsyncData(null);
    } catch (e, st) {
      String errMsg = '导入失败';
      if (e is DioException && e.response?.data != null) {
        errMsg = e.response?.data['error'] ?? errMsg;
      }
      state = AsyncError(errMsg, st);
    }
  }

  Future<void> importFromJwc({
    required String school,
    required String username,
    required String password,
    required int year,
    required String semester,
  }) async {
    state = const AsyncLoading();
    try {
      await _repository.importFromJwc(
        school: school,
        username: username,
        password: password,
        year: year,
        semester: semester,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      String errMsg = '教务系统登录失败或导入失败';
      if (e is DioException && e.response?.data != null) {
        errMsg = e.response?.data['error'] ?? errMsg;
      }
      state = AsyncError(errMsg, st);
    }
  }
}
