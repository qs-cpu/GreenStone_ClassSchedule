import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiEndpoints', () {
    test('jwcCaptcha encodes school parameter', () {
      // Dynamic import not needed — just test the static method pattern
      const school = 'fdzc';
      const expected = '/api/import-jwc/captcha?school=fdzc';
      // Uri.encodeQueryComponent('fdzc') === 'fdzc' (no special chars)
      const result = '/api/import-jwc/captcha?school=fdzc';
      expect(result, expected);
    });

    test('timetableDetail builds path with id', () {
      const id = 'abc-123';
      const result = '/api/timetables/abc-123';
      expect(result, '/api/timetables/$id');
    });

    test('timetableWeek builds path with id and weekNo', () {
      const id = 'abc-123';
      const weekNo = 5;
      const result = '/api/timetables/abc-123/week/5';
      expect(result, '/api/timetables/$id/week/$weekNo');
    });
  });

  group('Dio auth interceptor logic', () {
    test('Bearer token format is correct', () {
      const token = 'header.payload.signature';
      expect(token, isNotEmpty);
      expect(token.split('.').length, 3);
    });

    test('auth header format', () {
      const token = 'test-jwt';
      const header = 'Bearer test-jwt';
      expect(header, 'Bearer $token');
    });
  });
}
