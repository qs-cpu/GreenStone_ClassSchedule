import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/timetable_provider.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: detailAsync.when(
          data: (timetable) => Text(timetable?.title ?? '暂无课表', style: const TextStyle(fontWeight: FontWeight.bold)),
          loading: () => const Text('加载中...'),
          error: (_, __) => const Text('加载失败'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.source),
            tooltip: '数据来源管理',
            onPressed: () {
              context.push('/sources');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '设置',
            onPressed: () {
              // TODO: 跳转到设置页
            },
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
        _buildWeekDaysHeader(isDayView),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeColumn(),
                Expanded(child: _buildClassesGrid(context, timetable, isDayView)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekDaysHeader(bool isDayView) {
    final todayIndex = DateTime.now().weekday - 1;
    final days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final dates = ['1', '2', '3', '4', '5', '6', '7']; // 临时数据

    List<int> displayIndices = isDayView ? [todayIndex] : List.generate(7, (i) => i);

    return Container(
      padding: const EdgeInsets.only(left: 40, bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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

    List<Widget> children = [
      Row(
        children: List.generate(numCols, (index) => Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey.withOpacity(0.1)),
              ),
            ),
          ),
        )),
      ),
    ];

    for (var course in timetable.courses) {
      final color = _candyColors[course.id.hashCode.abs() % _candyColors.length];
      
      for (var session in course.sessions) {
        final sessionDayIndex = session.weekday - 1;
        
        // 如果是日视图，只显示今天的课程
        if (isDayView && sessionDayIndex != todayIndex) continue;
        
        final displayDayIndex = isDayView ? 0 : sessionDayIndex;

        children.add(_buildClassCard(
          context: context,
          dayIndex: displayDayIndex,
          numCols: numCols,
          startPeriod: session.startSection,
          duration: session.endSection - session.startSection + 1,
          title: course.title,
          room: session.note ?? '未知地点',
          color: color,
        ));
      }
    }

    return SizedBox(
      height: 60 * 12.0,
      child: Stack(
        children: children,
      ),
    );
  }

  Widget _buildClassCard({
    required BuildContext context,
    required int dayIndex,
    required int numCols,
    required int startPeriod,
    required int duration,
    required String title,
    required String room,
    required Color color,
  }) {
    final double height = duration * 60.0 - 4;
    final double top = (startPeriod - 1) * 60.0 + 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final colWidth = constraints.maxWidth / numCols;
        
        return Positioned(
          left: colWidth * dayIndex + 2,
          top: top,
          width: colWidth - 4,
          height: height,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.85),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
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
    );
  }
}
