import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/timetable_provider.dart';
import '../data/timetable_cache_repository.dart';
import '../domain/course.dart';
import '../domain/course_session.dart';
import '../domain/timetable.dart';
import '../../auth/application/auth_provider.dart';

// 用于控制日视图与周视图的切换
final isDayViewProvider = StateProvider<bool>((ref) => false);

class TimetableHomePage extends ConsumerWidget {
  const TimetableHomePage({super.key});

  static const List<Color> _candyColors = [
    Color(0xFFFFB3BA), // 粉
    Color(0xFFFFDFBA), // 橙
    Color(0xFFBAE1FF), // 蓝
    Color(0xFFBAFFC9), // 绿
    Color(0xFFE8DFF5), // 紫
    Color(0xFFFDFD96), // 黄
    Color(0xFFB5EAD7), // 青绿
    Color(0xFFC7CEEA), // 蓝紫
    Color(0xFFFFDAC1), // 杏
    Color(0xFFFF9AA2), // 红粉
  ];

  static const double _timeColumnWidth = 40;
  static const double _sectionHeight = 66;
  static const double _minWeekDayWidth = 76;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(currentTimetableDetailProvider);
    final timetablesAsync = ref.watch(timetablesProvider);
    final userInfo = ref.watch(userInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: detailAsync.when(
          data: (timetable) => Text(
            timetable?.title ?? '暂无课表',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          loading: () => const Text('加载中...'),
          error: (error, stackTrace) => const Text('加载失败'),
        ),
        actions: [
          if (userInfo?.isAdmin == true)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () => context.go('/admin'),
              tooltip: '管理后台',
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context, ref),
            tooltip: '退出登录',
          ),
          timetablesAsync.when(
            data: (timetables) => PopupMenuButton<String>(
              icon: const Icon(Icons.calendar_month),
              tooltip: '切换课表',
              enabled: timetables.isNotEmpty,
              onSelected: (id) {
                ref
                    .read(timetableCacheRepositoryProvider)
                    .setSelectedTimetableId(id);
                ref.read(selectedTimetableIdProvider.notifier).state = id;
                ref.invalidate(currentTimetableDetailProvider);
              },
              itemBuilder: (context) {
                final selectedId = ref.read(selectedTimetableIdProvider);
                final sortedTimetables = [...timetables]
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                return sortedTimetables.map((timetable) {
                  final isSelected =
                      selectedId == timetable.id ||
                      (selectedId == null &&
                          timetable.id == sortedTimetables.first.id);
                  final createdAt = timetable.createdAt;
                  final importedAt =
                      '${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')} '
                      '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';

                  return PopupMenuItem<String>(
                    value: timetable.id,
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 18,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
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
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
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
            error: (error, stackTrace) => IconButton(
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
              ),
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

  Widget _buildTimetableView(
    BuildContext context,
    WidgetRef ref,
    Timetable timetable,
  ) {
    final isDayView = ref.watch(isDayViewProvider);
    final unscheduledCourses = timetable.courses
        .where((course) => course.sessions.isEmpty)
        .toList();
    final hasScheduledCourses = timetable.courses.any(
      (course) => course.sessions.isNotEmpty,
    );

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
        else
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 当屏幕宽度大于 850 时，视为宽屏（Web/Desktop），显示右侧边栏
                final isWideScreen = constraints.maxWidth > 850;
                final sidePanelWidth = isWideScreen ? 280.0 : 0.0;

                final dayColumnWidth = isDayView
                    ? math.max(
                        _minWeekDayWidth,
                        constraints.maxWidth -
                            _timeColumnWidth -
                            sidePanelWidth,
                      )
                    : _minWeekDayWidth;
                final gridWidth = dayColumnWidth * (isDayView ? 1 : 7);
                final contentWidth = _timeColumnWidth + gridWidth;

                final mainContent = SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: math.max(
                        constraints.maxWidth - sidePanelWidth,
                        contentWidth,
                      ),
                      child: Column(
                        children: [
                          _buildWeekDaysHeader(
                            isDayView,
                            dayColumnWidth: dayColumnWidth,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTimeColumn(context),
                              SizedBox(
                                width: gridWidth,
                                child: _buildClassesGrid(
                                  context,
                                  timetable,
                                  isDayView,
                                ),
                              ),
                            ],
                          ),
                          if (unscheduledCourses.isNotEmpty && !isWideScreen)
                            SizedBox(
                              width: constraints.maxWidth,
                              child: _buildUnscheduledCourses(
                                context,
                                unscheduledCourses,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );

                if (isWideScreen) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: mainContent),
                      Container(
                        width: sidePanelWidth,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const WeatherCard(),
                              const SizedBox(height: 20),
                              if (unscheduledCourses.isNotEmpty)
                                _buildUnscheduledCourses(
                                  context,
                                  unscheduledCourses,
                                  isSidePanel: true,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return mainContent;
              },
            ),
          ),
      ],
    );
  }

  Widget _buildUnscheduledCourses(
    BuildContext context,
    List<Course> courses, {
    bool isSidePanel = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: isSidePanel
          ? EdgeInsets.zero
          : const EdgeInsets.fromLTRB(16, 12, 16, 88),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '未安排具体节次的课程',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: isSidePanel ? 14 : 16,
            ),
          ),
          const SizedBox(height: 8),
          ...courses.map((course) {
            final teacher = course.teacher;
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.55,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                ),
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
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: isSidePanel ? 12 : 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (teacher != null && teacher.isNotEmpty)
                          Text(
                            teacher,
                            style: TextStyle(
                              fontSize: isSidePanel ? 10 : 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
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

  Widget _buildWeekDaysHeader(
    bool isDayView, {
    required double dayColumnWidth,
  }) {
    final now = DateTime.now();
    final todayIndex = now.weekday - 1;
    final monday = now.subtract(Duration(days: todayIndex));

    final days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final dates = List.generate(
      7,
      (index) => monday.add(Duration(days: index)).day.toString(),
    );

    List<int> displayIndices = isDayView
        ? [todayIndex]
        : List.generate(7, (i) => i);

    return Container(
      padding: const EdgeInsets.only(left: _timeColumnWidth, bottom: 10),
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
          return SizedBox(
            width: dayColumnWidth,
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
                    color: isToday
                        ? const Color(0xFFFF7E9C)
                        : Colors.transparent,
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

  Widget _buildTimeColumn(BuildContext context) {
    return SizedBox(
      width: _timeColumnWidth,
      child: Stack(
        children: [
          // 贯穿整个时间轴的垂直轨道线
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Container(
              width: 2,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Column(
            children: List.generate(12, (index) {
              return SizedBox(
                height: _sectionHeight,
                child: Stack(
                  alignment: Alignment.topRight,
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 18, top: 4),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    // 时间轴节点圆点
                    Positioned(
                      right: 5,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildClassesGrid(
    BuildContext context,
    Timetable timetable,
    bool isDayView,
  ) {
    final todayIndex = DateTime.now().weekday - 1;
    final numCols = isDayView ? 1 : 7;
    final hasScheduledCourses = timetable.courses.any(
      (course) => course.sessions.isNotEmpty,
    );

    return SizedBox(
      height: hasScheduledCourses
          ? _sectionHeight * 12.0
          : _sectionHeight * 4.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final colWidth = constraints.maxWidth / numCols;
          final children = <Widget>[
            Positioned.fill(
              child: Row(
                children: List.generate(
                  numCols,
                  (index) => Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      child: Column(
                        children: List.generate(
                          12,
                          (i) => Container(
                            height: _sectionHeight,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.withValues(alpha: 0.05),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ];

          for (var course in timetable.courses) {
            for (var session in course.sessions) {
              final sessionDayIndex = session.weekday - 1;

              if (sessionDayIndex < 0 || sessionDayIndex >= 7) continue;
              // 如果是日视图，只显示今天的课程
              if (isDayView && sessionDayIndex != todayIndex) continue;

              final startPeriod = session.startSection.clamp(1, 12);
              final endPeriod = session.endSection.clamp(startPeriod, 12);
              final displayDayIndex = isDayView ? 0 : sessionDayIndex;

              children.add(
                _buildClassCard(
                  colWidth: colWidth,
                  dayIndex: displayDayIndex,
                  startPeriod: startPeriod,
                  duration: endPeriod - startPeriod + 1,
                  title: course.title,
                  room: session.location ?? session.note ?? '地点未公布',
                  color: _colorForSession(course, session),
                  isDayView: isDayView,
                ),
              );
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
    required bool isDayView,
  }) {
    // 日视图时增加较大边距并限制最大宽度，周视图保持紧凑
    final double hPadding = isDayView
        ? (colWidth > 400 ? (colWidth - 400) / 2 : 16.0)
        : 2.0;
    final double height = duration * _sectionHeight - (isDayView ? 12 : 6);
    final double top = (startPeriod - 1) * _sectionHeight + (isDayView ? 6 : 3);

    final titleMaxLines = duration <= 1 ? 2 : (duration <= 2 ? 4 : 6);
    final roomMaxLines = duration <= 1 ? 1 : 2;
    final titleFontSize = isDayView ? 15.0 : (duration <= 1 ? 11.0 : 12.0);
    final borderRadius = BorderRadius.circular(isDayView ? 16 : 10);

    return Positioned(
      left: colWidth * dayIndex + hPadding,
      top: top,
      width: colWidth - (hPadding * 2),
      height: height,
      child: Builder(
        builder: (context) => Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: () => _showCourseDetail(context, title: title, room: room),
            child: Ink(
              decoration: BoxDecoration(
                // 日视图采用浅色玻璃质感背景，周视图保持不透明
                color: isDayView
                    ? color.withValues(alpha: 0.25)
                    : color.withValues(alpha: 0.9),
                borderRadius: borderRadius,
                border: isDayView
                    ? Border.all(
                        color: color.withValues(alpha: 0.5),
                        width: 1.5,
                      )
                    : null,
                boxShadow: [
                  if (!isDayView)
                    BoxShadow(
                      color: color.withValues(alpha: 0.32),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  if (isDayView)
                    BoxShadow(
                      color: color.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Row(
                children: [
                  // 左侧深色主色强调条
                  if (isDayView)
                    Container(
                      width: 6,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDayView ? 14 : 6,
                        vertical: isDayView ? 12 : 6,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: titleFontSize,
                                height: 1.16,
                                fontWeight: FontWeight.w800,
                                color: isDayView
                                    ? Colors.black.withValues(alpha: 0.85)
                                    : Colors.black87,
                              ),
                              maxLines: titleMaxLines,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: isDayView ? 8 : 3),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 1),
                                child: Icon(
                                  Icons.location_on,
                                  size: isDayView ? 14 : 11,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(width: isDayView ? 4 : 1),
                              Expanded(
                                child: Text(
                                  room,
                                  style: TextStyle(
                                    fontSize: isDayView ? 12.0 : 10.5,
                                    height: 1.1,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: roomMaxLines,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _colorForSession(Course course, CourseSession session) {
    final key =
        '${course.title}-${session.weekday}-${session.startSection}-${session.endSection}-${session.location ?? ''}';
    return _candyColors[key.hashCode.abs() % _candyColors.length];
  }

  void _showCourseDetail(
    BuildContext context, {
    required String title,
    required String room,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, size: 18),
            const SizedBox(width: 6),
            Expanded(child: Text(room)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authStateProvider.notifier).logout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
}

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  late final Map<String, dynamic> _selectedWeather;

  static const List<Map<String, dynamic>> _weathers = [
    {
      'icon': Icons.wb_sunny_rounded,
      'iconColor': Color(0xFFFFA726),
      'temp': '27°C',
      'status': '晴空万里',
      'tip': '阳光明媚，又是充满活力的一天！去上课的路上走走吧~',
      'bgColor': Color(0xFFFFFDE7),
      'borderColor': Color(0xFFFFF59D),
    },
    {
      'icon': Icons.beach_access_rounded,
      'iconColor': Color(0xFF29B6F6),
      'temp': '21°C',
      'status': '细雨霏霏',
      'tip': '带上伞，听着雨声去教室，别迟到哦~',
      'bgColor': Color(0xFFE1F5FE),
      'borderColor': Color(0xFFB3E5FC),
    },
    {
      'icon': Icons.cloud_rounded,
      'iconColor': Color(0xFF78909C),
      'temp': '23°C',
      'status': '多云转阴',
      'tip': '温度适宜，微风不燥，最适合在图书馆自习了。',
      'bgColor': Color(0xFFECEFF1),
      'borderColor': Color(0xFFCFD8DC),
    },
    {
      'icon': Icons.air_rounded,
      'iconColor': Color(0xFF26A69A),
      'temp': '19°C',
      'status': '清风徐徐',
      'tip': '起风了，多穿一件外套，别让感冒影响学习！',
      'bgColor': Color(0xFFE0F2F1),
      'borderColor': Color(0xFFB2DFDB),
    },
  ];

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    _selectedWeather = _weathers[random.nextInt(_weathers.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _selectedWeather['bgColor'],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _selectedWeather['borderColor'], width: 1.5),
        boxShadow: [
          BoxShadow(
            color: (_selectedWeather['iconColor'] as Color).withValues(
              alpha: 0.1,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _selectedWeather['icon'] as IconData,
                color: _selectedWeather['iconColor'] as Color,
                size: 32,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedWeather['temp'] as String,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    _selectedWeather['status'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _selectedWeather['tip'] as String,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
