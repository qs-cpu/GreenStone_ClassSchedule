import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/source_provider.dart';

class SourceListPage extends ConsumerWidget {
  const SourceListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourcesAsync = ref.watch(sourcesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('课表来源管理')),
      body: sourcesAsync.when(
        data: (sources) {
          if (sources.isEmpty) {
            return const Center(child: Text('暂无来源数据'));
          }
          return ListView.builder(
            itemCount: sources.length,
            itemBuilder: (context, index) {
              final source = sources[index];
              return ListTile(
                title: Text(source.sourceType),
                subtitle: Text(
                  '最后同步: ${source.lastSyncedAt?.toLocal().toString() ?? "无"}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push('/sources/${source.id}');
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('加载失败: $err'),
              ElevatedButton(
                onPressed: () => ref.refresh(sourcesProvider),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
