import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/timetable_provider.dart';
import '../domain/course.dart';
import '../domain/timetable.dart';

// 用于控制日视图与周视图的切换
final isDayViewProvider = StateProvider<bool>((ref) => false);

class TimetableHomePage extends ConsumerWidget {
  const TimetableHomePage({super.key});

  static const List<Color> _candyColors = [
    Color(0xFFFFB3BA),
    Color(0xFFFFDFBA),
    Color(0xFFBAE1FF),
    Color(0xFFBaffC9),
    Color(0xFFE8DFF5),
    Color(0xFFFDFD96),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(currentTimetableDetailProvider);
    final timetablesAsync = ref.watch(timetablesProvider);

    return Scaffold(
      appBar: AppBar(
        title: detailAsync.when(
          data: (timetable) => Text(timetable?.title ?? '暂无课表', style: const TextStyle(fontWeight: FontWeight.bold)),
          loading: () => const Text('加载中...'),
          error: (_, __) => const Text('加载失败'),
        ),
        actions: [
          timetablesAsync.when(
            data: (timetables) => PopupMenuButton<String>(
              icon: const Icon(Icons.calendar_month),
              tooltip: '切换课表',
              enabled: timetables.isNotEmpty,
              onSelected: (id) {
                ref.read(selectedTimetableIdProvider.notifier).state = id;
                ref.invalidate(currentTimetableDetailProvider);
              },
              itemBuilder: (context) {
                final selectedId = ref.read(selectedTimetableIdProvider);
                final sortedTimetables = [...timetables]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                return sortedTimetables.map((timetable) {
                  final isSelected = selectedId == timetable.id ||
                      (selectedId == null && timetable.id == sortedTimetables.first.id);
                  final createdAt = timetable.createdAt;
                  final importedAt =
                      '${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')} '
                      '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';

                  return PopupMenuItem<String>(
                    value: timetable.id,
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                          size: 18,
                          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                timetable.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                importedAt,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
            loading: () => const SizedBox(
              width: 48,
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (_, __) => IconButton(
              icon: const Icon(Icons.calendar_month),
              tooltip: '课表列表加载失败',
              onPressed: () => ref.invalidate(timetablesProvider),
            ),
          ),
        ],
      ),
      body: detailAsync.when(
        data: (timetable) {
          if (timetable == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('暂无课表，请导入'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.push('/import'),
                    child: const Text('去导入'),
                  ),
                ],
              ),
            );
          }
          return _buildTimetableView(context, ref, timetable);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('出错了: $err'),
              ElevatedButton(
                onPressed: () => ref.refresh(currentTimetableDetailProvider),
                child: const Text('重试'),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/import'),
        icon: const Icon(Icons.import_export),
        label: const Text('导入课表'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }

  Widget _buildTimetableView(BuildContext context, WidgetRef ref, Timetable timetable) {
    final isDayView = ref.watch(isDayViewProvider);
    final unscheduledCourses = timetable.courses.where((course) => course.sessions.isEmpty).toList();
    final hasScheduledCourses = timetable.courses.any((course) => course.sessions.isNotEmpty);

    return Column(
      children: [
        // 视图切换控制
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('周视图')),
              ButtonSegment(value: true, label: Text('日视图')),
            ],
            selected: {isDayView},
            onSelectionChanged: (Set<bool> newSelection) {
              ref.read(isDayViewProvider.notifier).state = newSelection.first;
            },
          ),
        ),
        if (!hasScheduledCourses && unscheduledCourses.isNotEmpty)
          Expanded(
            child: SingleChildScrollView(
              child: _buildUnscheduledCourses(context, unscheduledCourses),
            ),
          )
        else ...[
          _buildWeekDaysHeader(isDayView),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTimeColumn(),
                      Expanded(child: _buildClassesGrid(context, timetable, isDayView)),
                    ],
                  ),
                  if (unscheduledCourses.isNotEmpty)
                    _buildUnscheduledCourses(context, unscheduledCourses),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUnscheduledCourses(BuildContext context, List<Course> courses) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '未安排具体节次的课程',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...courses.map((course) {
            final teacher = course.teacher;
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
              ),
              child: Row(
                children: [
                  Icon(Icons.event_note, color: colorScheme.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (teacher != null && teacher.isNotEmpty)
                          Text(
                            teacher,
                            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWeekDaysHeader(bool isDayView) {
    final now = DateTime.now();
    final todayIndex = now.weekday - 1;
    final monday = now.subtract(Duration(days: todayIndex));
    
    final days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final dates = List.generate(7, (index) => monday.add(Duration(days: index)).day.toString());

    List<int> displayIndices = isDayView ? [todayIndex] : List.generate(7, (i) => i);

    return Container(
      padding: const EdgeInsets.only(left: 40, bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: displayIndices.map((index) {
          final isToday = index == todayIndex;
          return Expanded(
            child: Column(
              children: [
                Text(
                  days[index],
                  style: TextStyle(
                    fontSize: 12,
                    color: isToday ? const Color(0xFFFF7E9C) : Colors.grey[600],
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isToday ? const Color(0xFFFF7E9C) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    dates[index],
                    style: TextStyle(
                      fontSize: 14,
                      color: isToday ? Colors.white : Colors.black87,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeColumn() {
    return SizedBox(
      width: 40,
      child: Column(
        children: List.generate(12, (index) {
          return Container(
            height: 60,
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildClassesGrid(BuildContext context, Timetable timetable, bool isDayView) {
    final todayIndex = DateTime.now().weekday - 1;
    final numCols = isDayView ? 1 : 7;
    final hasScheduledCourses = timetable.courses.any((course) => course.sessions.isNotEmpty);

    return SizedBox(
      height: hasScheduledCourses ? 60 * 12.0 : 60 * 4.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final colWidth = constraints.maxWidth / numCols;
          final children = <Widget>[
            Positioned.fill(
              child: Row(
                children: List.generate(numCols, (index) => Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                      ),
                    ),
                  ),
                )),
              ),
            ),
          ];

          for (var course in timetable.courses) {
            final color = _candyColors[course.id.hashCode.abs() % _candyColors.length];

            for (var session in course.sessions) {
              final sessionDayIndex = session.weekday - 1;

              if (sessionDayIndex < 0 || sessionDayIndex >= 7) continue;
              // 如果是日视图，只显示今天的课程
              if (isDayView && sessionDayIndex != todayIndex) continue;

              final startPeriod = session.startSection.clamp(1, 12);
              final endPeriod = session.endSection.clamp(startPeriod, 12);
              final displayDayIndex = isDayView ? 0 : sessionDayIndex;

              children.add(_buildClassCard(
                colWidth: colWidth,
                dayIndex: displayDayIndex,
                startPeriod: startPeriod,
                duration: endPeriod - startPeriod + 1,
                title: course.title,
                room: session.location ?? session.note ?? '地点未公布',
                color: color,
              ));
            }
          }

          return Stack(children: children);
        },
      ),
    );
  }

  Widget _buildClassCard({
    required double colWidth,
    required int dayIndex,
    required int startPeriod,
    required int duration,
    required String title,
    required String room,
    required Color color,
  }) {
    final double height = duration * 60.0 - 4;
    final double top = (startPeriod - 1) * 60.0 + 2;

    return Positioned(
      left: colWidth * dayIndex + 2,
      top: top,
      width: colWidth - 4,
      height: height,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.location_on, size: 10, color: Colors.black54),
                Expanded(
                  child: Text(
                    room,
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
