import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/source_repository.dart';
import '../domain/timetable_source.dart';

final sourcesProvider = FutureProvider<List<TimetableSource>>((ref) async {
  return ref.read(sourceRepositoryProvider).getSources();
});

final sourceDetailProvider = FutureProvider.family<TimetableSource, String>((ref, id) async {
  return ref.read(sourceRepositoryProvider).getSourceDetail(id);
});

final syncSourceProvider = StateNotifierProvider<SyncNotifier, AsyncValue<void>>((ref) {
  return SyncNotifier(ref.read(sourceRepositoryProvider));
});

class SyncNotifier extends StateNotifier<AsyncValue<void>> {
  final SourceRepository _repository;

  SyncNotifier(this._repository) : super(const AsyncData(null));

  Future<void> syncSource(String id, WidgetRef ref) async {
    state = const AsyncLoading();
    try {
      await _repository.syncSource(id);
      // 成功后强制刷新详情页面数据
      ref.invalidate(sourceDetailProvider(id));
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
