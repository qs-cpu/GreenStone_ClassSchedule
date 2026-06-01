import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/admin_provider.dart';
import '../data/admin_repository.dart';

class AdminUserListPage extends ConsumerStatefulWidget {
  const AdminUserListPage({super.key});

  @override
  ConsumerState<AdminUserListPage> createState() => _AdminUserListPageState();
}

class _AdminUserListPageState extends ConsumerState<AdminUserListPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(adminUserListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('用户管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateUserDialog(context),
            tooltip: '创建用户',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: '搜索用户名',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      ref.read(adminUserListProvider.notifier).search(value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                FilledButton(
                  onPressed: () {
                    ref
                        .read(adminUserListProvider.notifier)
                        .search(_searchController.text);
                  },
                  child: const Text('搜索'),
                ),
              ],
            ),
          ),
          Expanded(
            child: usersState.when(
              data: (data) => _buildUserList(data),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载失败: $e')),
            ),
          ),
          _buildPagination(usersState),
        ],
      ),
    );
  }

  Widget _buildUserList(Map<String, dynamic> data) {
    final users = data['users'] as List;

    if (users.isEmpty) {
      return const Center(child: Text('没有找到用户'));
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(child: Text(user['username'][0].toUpperCase())),
          title: Text(user['username']),
          subtitle: Text(user['nickname'] ?? ''),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Chip(
                label: Text(user['role'] == 'admin' ? '管理员' : '用户'),
                backgroundColor: user['role'] == 'admin'
                    ? Colors.orange.shade100
                    : Colors.grey.shade200,
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditUserDialog(context, user),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeleteConfirmDialog(context, user),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPagination(AsyncValue<Map<String, dynamic>> usersState) {
    return usersState.when(
      data: (data) {
        final page = data['page'] as int;
        final totalPages = data['totalPages'] as int;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: page > 1
                    ? () => ref.read(adminUserListProvider.notifier).prevPage()
                    : null,
              ),
              Text('第 $page 页 / 共 $totalPages 页'),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: page < totalPages
                    ? () => ref.read(adminUserListProvider.notifier).nextPage()
                    : null,
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Future<void> _showCreateUserDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _UserFormDialog(),
    );
    if (result != null) {
      try {
        await ref
            .read(adminRepositoryProvider)
            .createUser(
              username: result['username'],
              password: result['password'],
              nickname: result['nickname'],
              role: result['role'] ?? 'user',
            );
        ref.read(adminUserListProvider.notifier).loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('用户创建成功')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('创建失败: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _showEditUserDialog(
    BuildContext context,
    Map<String, dynamic> user,
  ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _UserFormDialog(user: user),
    );
    if (result != null) {
      try {
        await ref
            .read(adminRepositoryProvider)
            .updateUser(
              id: user['id'],
              nickname: result['nickname'],
              role: result['role'],
              password: result['password'],
            );
        ref.read(adminUserListProvider.notifier).loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('用户更新成功')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('更新失败: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _showDeleteConfirmDialog(
    BuildContext context,
    Map<String, dynamic> user,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除用户 ${user['username']} 吗？\n\n删除后该用户的所有数据将被永久删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(adminRepositoryProvider).deleteUser(user['id']);
        ref.read(adminUserListProvider.notifier).loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('用户已删除')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}

class _UserFormDialog extends StatefulWidget {
  final Map<String, dynamic>? user;

  const _UserFormDialog({this.user});

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _username;
  late String _nickname;
  String _password = '';
  String _role = 'user';

  @override
  void initState() {
    super.initState();
    _username = widget.user?['username'] ?? '';
    _nickname = widget.user?['nickname'] ?? '';
    _role = widget.user?['role'] ?? 'user';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;

    return AlertDialog(
      title: Text(isEditing ? '编辑用户' : '创建用户'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _username,
              decoration: const InputDecoration(labelText: '用户名'),
              enabled: !isEditing,
              validator: (v) => v == null || v.isEmpty ? '请输入用户名' : null,
              onSaved: (v) => _username = v!,
            ),
            TextFormField(
              initialValue: _nickname,
              decoration: const InputDecoration(labelText: '昵称'),
              onSaved: (v) => _nickname = v ?? '',
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: isEditing ? '新密码（留空不修改）' : '密码',
              ),
              obscureText: true,
              validator: (v) {
                if (!isEditing && (v == null || v.length < 6)) {
                  return '密码至少6位';
                }
                return null;
              },
              onSaved: (v) => _password = v ?? '',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _role,
              decoration: const InputDecoration(labelText: '角色'),
              items: const [
                DropdownMenuItem(value: 'user', child: Text('普通用户')),
                DropdownMenuItem(value: 'admin', child: Text('管理员')),
              ],
              onChanged: (v) => setState(() => _role = v!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              Navigator.pop(context, {
                'username': _username,
                'nickname': _nickname,
                'password': _password,
                'role': _role,
              });
            }
          },
          child: Text(isEditing ? '保存' : '创建'),
        ),
      ],
    );
  }
}
