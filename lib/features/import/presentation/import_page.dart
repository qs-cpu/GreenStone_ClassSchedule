import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/import_provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

class ImportPage extends ConsumerStatefulWidget {
  const ImportPage({super.key});

  @override
  ConsumerState<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends ConsumerState<ImportPage> {
  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(importStateProvider, (_, state) {
      state.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString()), backgroundColor: Theme.of(context).colorScheme.error),
          );
        },
        data: (_) {
          if (!state.isLoading && !state.hasError) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('导入成功！'), backgroundColor: Colors.green),
            );
            context.pop(); // 返回上一页
          }
        },
      );
    });

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('导入课表', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            tabs: [
              Tab(text: '教务系统导入'),
              Tab(text: 'URL 链接导入'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            JwcImportTab(),
            UrlImportTab(),
          ],
        ),
      ),
    );
  }
}

class JwcImportTab extends ConsumerStatefulWidget {
  const JwcImportTab({super.key});

  @override
  ConsumerState<JwcImportTab> createState() => _JwcImportTabState();
}

class _JwcImportTabState extends ConsumerState<JwcImportTab> {
  final _formKey = GlobalKey<FormState>();
  String _school = 'fdzc';
  String _username = '';
  String _password = '';
  int _year = DateTime.now().year;
  String _semester = '上';
  String _captcha = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(captchaProvider.notifier).fetchCaptcha(_school);
    });
  }

  @override
  Widget build(BuildContext context) {
    final importState = ref.watch(importStateProvider);
    final captchaState = ref.watch(captchaProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: _school,
              decoration: const InputDecoration(
                labelText: '选择学校',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'fdzc', child: Text('福州大学至诚学院')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _school = val);
                  ref.read(captchaProvider.notifier).fetchCaptcha(_school);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: '学号', border: OutlineInputBorder()),
              validator: (val) => (val == null || val.isEmpty) ? '请输入学号' : null,
              onSaved: (val) => _username = val!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: '密码', border: OutlineInputBorder()),
              obscureText: true,
              validator: (val) => (val == null || val.isEmpty) ? '请输入密码' : null,
              onSaved: (val) => _password = val!,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _year.toString(),
                    decoration: const InputDecoration(labelText: '学年 (如 2024)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onSaved: (val) => _year = int.tryParse(val ?? '') ?? 2024,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _semester,
                    decoration: const InputDecoration(labelText: '学期', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: '上', child: Text('上学期')),
                      DropdownMenuItem(value: '下', child: Text('下学期')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _semester = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: '验证码', border: OutlineInputBorder()),
                    validator: (val) => (val == null || val.isEmpty) ? '请输入验证码' : null,
                    onSaved: (val) => _captcha = val!,
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () => ref.read(captchaProvider.notifier).fetchCaptcha(_school),
                  child: Container(
                    height: 56,
                    width: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: captchaState.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : captchaState.captchaImage != null
                            ? _buildBase64Image(captchaState.captchaImage!)
                            : const Center(child: Text('获取失败，点击重试', style: TextStyle(fontSize: 12))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: importState.isLoading || captchaState.captchaId == null
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        ref.read(importStateProvider.notifier).importFromJwc(
                              school: _school,
                              username: _username,
                              password: _password,
                              year: _year,
                              semester: _semester,
                              captchaId: captchaState.captchaId!,
                              captcha: _captcha,
                            );
                      }
                    },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: importState.isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('立即导入', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBase64Image(String base64String) {
    try {
      final String base64Image = base64String.split(',').last;
      return Image.memory(
        base64Decode(base64Image),
        fit: BoxFit.fill,
      );
    } catch (e) {
      return const Center(child: Text('图片格式错误', style: TextStyle(fontSize: 12)));
    }
  }
}

class UrlImportTab extends ConsumerStatefulWidget {
  const UrlImportTab({super.key});

  @override
  ConsumerState<UrlImportTab> createState() => _UrlImportTabState();
}

class _UrlImportTabState extends ConsumerState<UrlImportTab> {
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final importState = ref.watch(importStateProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '支持从 .ics 文件链接或受支持的 JSON API 导入。如果是教务系统导入，请切换到左侧标签页。',
              style: TextStyle(color: Colors.black87),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: '课表订阅 URL',
              border: OutlineInputBorder(),
              hintText: 'https://example.com/timetable.ics',
              prefixIcon: Icon(Icons.link),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: importState.isLoading
                ? null
                : () {
                    final url = _urlController.text.trim();
                    if (url.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请输入有效的 URL')),
                      );
                      return;
                    }
                    ref.read(importStateProvider.notifier).importFromUrl(url);
                  },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: importState.isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('开始解析并导入', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
