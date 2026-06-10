import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:schedule/features/auth/application/auth_provider.dart';

import '../../helpers/secure_storage_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    mockSecureStorageChannel();
  });

  group('TokenNotifier', () {
    test('initial state is the initial token', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = TokenNotifier(
        prefs,
        const FlutterSecureStorage(),
        'initial-token',
      );

      expect(notifier.state, 'initial-token');
    });

    test('initial state is null when no token provided', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = TokenNotifier(prefs, const FlutterSecureStorage(), null);

      expect(notifier.state, isNull);
    });

    test('setToken updates state', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = TokenNotifier(prefs, const FlutterSecureStorage(), null);

      await notifier.setToken('new-token');

      expect(notifier.state, 'new-token');
    });

    test('clearToken sets state to null', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = TokenNotifier(
        prefs,
        const FlutterSecureStorage(),
        'some-token',
      );

      expect(notifier.state, 'some-token');
      await notifier.clearToken();
      expect(notifier.state, isNull);
    });

    test('setToken removes old key from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'jwt_token': 'old-legacy'});
      final prefs = await SharedPreferences.getInstance();
      final notifier = TokenNotifier(prefs, const FlutterSecureStorage(), null);

      await notifier.setToken('fresh-token');
      expect(prefs.getString('jwt_token'), isNull);
      expect(notifier.state, 'fresh-token');
    });
  });
}
