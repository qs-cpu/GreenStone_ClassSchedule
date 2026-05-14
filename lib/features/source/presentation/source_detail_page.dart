import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/source_provider.dart';

class SourceDetailPage extends ConsumerWidget {
  final String sourceId;
  const SourceDetailPage({super.key, required this.sourceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(sourceDetailProvider(sourceId));
    final syncState = ref.watch(syncSourceProvider);

    ref.listen<AsyncValue<void>>(syncSourceProvider, (_, state) {
      state.whenOrNull(
        data: (_) {
          if (!state.isLoading && !state.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('同步成功'), backgroundColor: Colors.green));
          }
        },
        error: (err, _) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('同步失败: $err'), backgroundColor: Colors.red));
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('来源详情'),
        actions: [
          IconButton(
            icon: syncState.isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.sync),
            onPressed: syncState.isLoading ? null : () {
              ref.read(syncSourceProvider.notifier).syncSource(sourceId);
            },
            tooltip: '手动同步',
          ),
        ],
      ),
      body: detailAsync.when(
        data: (source) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildInfoCard('基本信息', [
                '来源类型: ${source.sourceType}',
                '同步状态: ${source.syncStatus}',
                '原始链接: ${source.originalUrl}',
                '创建时间: ${source.createdAt.toLocal().toString().split('.')[0]}',
              ]),
              const SizedBox(height: 24),
              const Text('近期同步记录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (source.syncRecords.isEmpty) const Text('暂无记录', style: TextStyle(color: Colors.grey)),
              ...source.syncRecords.map((record) => Card(
                child: ListTile(
                  leading: Icon(
                    record.status == 'success' ? Icons.check_circle : Icons.error,
                    color: record.status == 'success' ? Colors.green : Colors.red,
                  ),
                  title: Text('状态: ${record.status}'),
                  subtitle: Text('时间: ${record.startedAt.toLocal().toString().split('.')[0]}'),
                ),
              )).toList(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('加载失败: $err')),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<String> lines) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            ...lines.map((line) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(line, style: const TextStyle(fontSize: 14)),
            )).toList(),
          ],
        ),
      ),
    );
  }
}
