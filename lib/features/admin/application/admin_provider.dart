import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/admin_repository.dart';

final adminUserListProvider =
    StateNotifierProvider<
      AdminUserListNotifier,
      AsyncValue<Map<String, dynamic>>
    >((ref) {
      return AdminUserListNotifier(ref);
    });

class AdminUserListNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final Ref _ref;
  int _currentPage = 1;
  String? _search;

  AdminUserListNotifier(this._ref) : super(const AsyncLoading()) {
    loadUsers();
  }

  Future<void> loadUsers({int? page, String? search}) async {
    _currentPage = page ?? _currentPage;
    _search = search ?? _search;
    state = const AsyncLoading();
    try {
      final repo = _ref.read(adminRepositoryProvider);
      final data = await repo.getUsers(page: _currentPage, search: _search);
      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> nextPage() async {
    if (state.hasValue) {
      final totalPages = state.value!['totalPages'] as int;
      if (_currentPage < totalPages) {
        await loadUsers(page: _currentPage + 1);
      }
    }
  }

  Future<void> prevPage() async {
    if (_currentPage > 1) {
      await loadUsers(page: _currentPage - 1);
    }
  }

  Future<void> search(String query) async {
    await loadUsers(page: 1, search: query);
  }
}

final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.read(adminRepositoryProvider);
  return repo.getStats();
});
