import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TimetableHomePage extends StatelessWidget {
  const TimetableHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('本周课表', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 跳转到设置页
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildWeekDaysHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimeColumn(),
                  Expanded(child: _buildClassesGrid()),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/import'); // 点击跳转到导入页
        },
        icon: const Icon(Icons.import_export),
        label: const Text('导入课表'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }

  Widget _buildWeekDaysHeader() {
    final days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final dates = ['1', '2', '3', '4', '5', '6', '7'];
    
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
        children: List.generate(7, (index) {
          final isToday = index == 2; // 假设周三是今天
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
        }),
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

  Widget _buildClassesGrid() {
    return SizedBox(
      height: 60 * 12.0,
      child: Stack(
        children: [
          Row(
            children: List.generate(7, (index) => Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.grey.withOpacity(0.1)),
                  ),
                ),
              ),
            )),
          ),
          _buildClassCard(dayIndex: 0, startPeriod: 1, duration: 2, title: '高等数学', room: '理1-102', color: const Color(0xFFFFB3BA)),
          _buildClassCard(dayIndex: 0, startPeriod: 3, duration: 2, title: '大学物理', room: '理2-204', color: const Color(0xFFFFDFBA)),
          _buildClassCard(dayIndex: 1, startPeriod: 1, duration: 2, title: '数据结构', room: '计3-301', color: const Color(0xFFBAE1FF)),
          _buildClassCard(dayIndex: 2, startPeriod: 3, duration: 2, title: '英语', room: '文1-105', color: const Color(0xFFBaffC9)),
          _buildClassCard(dayIndex: 3, startPeriod: 6, duration: 3, title: '计算机网络', room: '计1-402', color: const Color(0xFFE8DFF5)),
          _buildClassCard(dayIndex: 4, startPeriod: 1, duration: 2, title: '体育', room: '操场', color: const Color(0xFFFDFD96)),
        ],
      ),
    );
  }

  Widget _buildClassCard({
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
      left: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width / 7 * dayIndex + 2,
      top: top,
      width: (MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width - 40) / 7 - 4,
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
}
