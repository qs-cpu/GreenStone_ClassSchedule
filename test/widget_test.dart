import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:schedule/main.dart';
import 'package:schedule/features/auth/application/auth_provider.dart';

/// Mock the FlutterSecureStorage platform channel so widget tests don't crash.
/// All read operations return null (empty storage).
void _mockSecureStorageChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        (MethodCall methodCall) async => null,
      );
}

Widget pumpApp({String? initialToken, required SharedPreferences prefs}) {
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      initialTokenProvider.overrideWithValue(initialToken),
    ],
    child: const MyApp(),
  );
}

void main() {
  setUp(() {
    _mockSecureStorageChannel();
  });

  testWidgets('redirects to login when no token', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(pumpApp(initialToken: null, prefs: prefs));
    await tester.pumpAndSettle();

    // 未登录 → 重定向到 /login，应看到登录按钮
    expect(find.text('登录'), findsOneWidget);
  });

  testWidgets('renders app bar when token present', (tester) async {
    SharedPreferences.setMockInitialValues({
      'user_info': '{"id":"t","username":"t","nickname":"T","role":"user"}',
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(pumpApp(initialToken: 'fake-token', prefs: prefs));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsOneWidget);
  });
}
