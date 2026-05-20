import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/source_repository.dart';
import '../domain/timetable_source.dart';

final sourcesProvider = FutureProvider<List<TimetableSource>>((ref) async {
  return ref.read(sourceRepositoryProvider).getSources();
});

final sourceDetailProvider = FutureProvider.family<TimetableSource, String>((
  ref,
  id,
) async {
  return ref.read(sourceRepositoryProvider).getSourceDetail(id);
});

final syncSourceProvider =
    StateNotifierProvider<SyncNotifier, AsyncValue<void>>((ref) {
      return SyncNotifier(ref);
    });

class SyncNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  SyncNotifier(this._ref) : super(const AsyncData(null));

  Future<void> syncSource(String id) async {
    state = const AsyncLoading();
    try {
      final repository = _ref.read(sourceRepositoryProvider);
      await repository.syncSource(id);
      // 成功后强制刷新详情页面数据
      _ref.invalidate(sourceDetailProvider(id));
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
