import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:schedule/main.dart';
import 'package:schedule/features/auth/application/auth_provider.dart';
import '../helpers/secure_storage_mock.dart';

/// Pump the app with mocked storage and an optional token.
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
    mockSecureStorageChannel();
  });

  testWidgets('redirects to /login when no token', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(pumpApp(initialToken: null, prefs: prefs));
    await tester.pumpAndSettle();

    expect(find.text('登录'), findsOneWidget);
  });

  testWidgets('renders app bar when token present', (tester) async {
    SharedPreferences.setMockInitialValues({
      'user_info':
          '{"id":"test","username":"test","nickname":"Test","role":"user"}',
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(pumpApp(initialToken: 'fake-token', prefs: prefs));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('redirects from /login to / when already logged in',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'user_info':
          '{"id":"test","username":"test","nickname":"Test","role":"user"}',
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(pumpApp(initialToken: 'fake-token', prefs: prefs));
    await tester.pumpAndSettle();

    // Should NOT see the login page — should be redirected to /
    expect(find.text('登录'), findsNothing);
    expect(find.byType(AppBar), findsOneWidget);
  });
}
