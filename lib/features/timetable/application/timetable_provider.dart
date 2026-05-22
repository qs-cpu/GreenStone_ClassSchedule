import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/timetable_cache_repository.dart';
import '../data/timetable_repository.dart';
import '../domain/timetable.dart';

// 提供所有的课表列表
final timetablesProvider = FutureProvider<List<Timetable>>((ref) async {
  final repo = ref.read(timetableRepositoryProvider);
  return await repo.getTimetables();
});

// 当前选中的课表 ID
final selectedTimetableIdProvider = StateProvider<String?>((ref) {
  return ref.watch(timetableCacheRepositoryProvider).getSelectedTimetableId();
});

// 当前选中的课表详情数据 (根据选中的 ID 自动拉取详情)
final currentTimetableDetailProvider = FutureProvider<Timetable?>((ref) async {
  final selectedId = ref.watch(selectedTimetableIdProvider);
  final repo = ref.read(timetableRepositoryProvider);

  if (selectedId == null) {
    // 如果没有选中，尝试拉取列表里的第一个作为默认
    final list = await ref.watch(timetablesProvider.future);
    if (list.isNotEmpty) {
      final sortedList = [...list]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final timetable = await repo.getTimetableDetail(sortedList.first.id);
      ref.read(selectedTimetableIdProvider.notifier).state = timetable.id;
      return timetable;
    }
    return null; // 用户没有任何课表
  } else {
    return await repo.getTimetableDetail(selectedId);
  }
});
