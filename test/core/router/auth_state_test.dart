import 'package:flutter_test/flutter_test.dart';
import 'package:smart_univ/core/router/auth_state.dart';

void main() {
  group('AuthState', () {
    late AuthState authState;

    setUp(() => authState = AuthState());
    tearDown(() => authState.dispose());

    test('starts logged out', () {
      expect(authState.isLoggedIn, isFalse);
    });

    test('login() sets isLoggedIn to true', () {
      authState.login();
      expect(authState.isLoggedIn, isTrue);
    });

    test('logout() sets isLoggedIn to false', () {
      authState.login();
      authState.logout();
      expect(authState.isLoggedIn, isFalse);
    });

    test('login() notifies listeners', () {
      var notified = false;
      authState.addListener(() => notified = true);
      authState.login();
      expect(notified, isTrue);
    });

    test('logout() notifies listeners', () {
      authState.login();
      var notified = false;
      authState.addListener(() => notified = true);
      authState.logout();
      expect(notified, isTrue);
    });
  });
}
