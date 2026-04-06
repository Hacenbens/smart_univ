sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'A network error occurred']);
}

class AuthException extends AppException {
  const AuthException([super.message = 'An authentication error occurred']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'A cache error occurred']);
}

class PermissionException extends AppException {
  const PermissionException([super.message = 'Permission denied']);
}
