import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:smart_univ/core/network/token_provider.dart';

class Auth0TokenProvider implements TokenProvider {
  final CredentialsManager _credentialsManager;

  Auth0TokenProvider(this._credentialsManager);

  @override
  Future<String?> getToken() async {
    try {
      final credentials = await _credentialsManager.credentials();
      return credentials.accessToken;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> refreshToken() async {
    try {
      final credentials = await _credentialsManager.renewCredentials();
      return credentials.accessToken;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearToken() async {
    await _credentialsManager.clearCredentials();
  }
}
