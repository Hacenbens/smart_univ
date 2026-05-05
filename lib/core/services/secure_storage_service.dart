import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const accessKey = 'auth_access';
  static const refreshKey = 'auth_refresh';
  static const expiryKey = 'auth_expiry';
  static const credentialsKey = 'auth_credentials';

  final FlutterSecureStorage _storage;

  SecureStorageService([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  Future<void> saveToken(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<String?> readToken(String key) => _storage.read(key: key);

  Future<void> deleteToken(String key) => _storage.delete(key: key);

  Future<void> deleteAll() => _storage.deleteAll();
}
