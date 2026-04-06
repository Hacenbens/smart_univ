import 'package:flutter_test/flutter_test.dart';
import 'package:smart_univ/core/error/app_exception.dart';

void main() {
  group('AppException', () {
    test('NetworkException has default message', () {
      const e = NetworkException();
      expect(e.message, 'A network error occurred');
      expect(e, isA<AppException>());
    });

    test('NetworkException accepts custom message', () {
      const e = NetworkException('No internet');
      expect(e.message, 'No internet');
    });

    test('AuthException has default message', () {
      const e = AuthException();
      expect(e.message, 'An authentication error occurred');
    });

    test('CacheException has default message', () {
      const e = CacheException();
      expect(e.message, 'A cache error occurred');
    });

    test('PermissionException has default message', () {
      const e = PermissionException();
      expect(e.message, 'Permission denied');
    });

    test('sealed class exhaustive pattern matching', () {
      AppException exception = const AuthException('bad token');
      final label = switch (exception) {
        NetworkException() => 'network',
        AuthException() => 'auth',
        CacheException() => 'cache',
        PermissionException() => 'permission',
      };
      expect(label, 'auth');
    });
  });
}
