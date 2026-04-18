import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_univ/data/datasources/auth0_token_provider.dart';

class MockCredentialsManager extends Mock implements CredentialsManager {}

Credentials _fakeCredentials({String accessToken = 'test_access_token'}) =>
    Credentials(
      accessToken: accessToken,
      idToken: 'test_id_token',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      scopes: const {'openid', 'profile'},
      user: UserProfile(sub: 'auth0|123'),
      tokenType: 'Bearer',
    );

void main() {
  late MockCredentialsManager mockManager;
  late Auth0TokenProvider provider;

  setUp(() {
    mockManager = MockCredentialsManager();
    provider = Auth0TokenProvider(mockManager);
  });

  group('getToken', () {
    test('returns accessToken on success', () async {
      when(() => mockManager.credentials()).thenAnswer(
        (_) async => _fakeCredentials(accessToken: 'valid_token'),
      );

      final token = await provider.getToken();

      expect(token, 'valid_token');
    });

    test('returns null when credentials() throws', () async {
      when(() => mockManager.credentials()).thenThrow(Exception('no creds'));

      final token = await provider.getToken();

      expect(token, isNull);
    });
  });

  group('refreshToken', () {
    test('returns new accessToken via renewCredentials()', () async {
      when(() => mockManager.renewCredentials()).thenAnswer(
        (_) async => _fakeCredentials(accessToken: 'refreshed_token'),
      );

      final token = await provider.refreshToken();

      expect(token, 'refreshed_token');
    });

    test('returns null when renewCredentials() throws', () async {
      when(() => mockManager.renewCredentials())
          .thenThrow(Exception('refresh failed'));

      final token = await provider.refreshToken();

      expect(token, isNull);
    });
  });

  group('clearToken', () {
    test('calls clearCredentials()', () async {
      when(() => mockManager.clearCredentials()).thenAnswer((_) async => true);

      await provider.clearToken();

      verify(() => mockManager.clearCredentials()).called(1);
    });
  });
}
