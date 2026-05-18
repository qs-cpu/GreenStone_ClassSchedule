import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen<AsyncValue<void>>(authStateProvider, (_, state) {
      state.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString()), backgroundColor: Theme.of(context).colorScheme.error),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.calendar_month, size: 80, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 32),
                  const Text('GreenStone 课程表', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),
                  TextFormField(
                    decoration: const InputDecoration(labelText: '用户名', border: OutlineInputBorder()),
                    validator: (val) => (val == null || val.isEmpty) ? '请输入用户名' : null,
                    onSaved: (val) => _username = val!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: '密码', border: OutlineInputBorder()),
                    obscureText: true,
                    validator: (val) => (val == null || val.isEmpty) ? '请输入密码' : null,
                    onSaved: (val) => _password = val!,
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: authState.isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              ref.read(authStateProvider.notifier).login(_username, _password).then((_) {
                                // 如果没有抛出异常（即 hasError 为 false），由于有了全局路由守卫，会自动被重定向到 /
                              });
                            }
                          },
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: authState.isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('登录', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: const Text('没有账号？去注册'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
