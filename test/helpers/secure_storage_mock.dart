import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mock the FlutterSecureStorage platform channel so tests don't crash.
/// All read/write/delete calls succeed silently.
void mockSecureStorageChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        (MethodCall methodCall) async => null,
      );
}
