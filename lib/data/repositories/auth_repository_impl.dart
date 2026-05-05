import 'dart:convert';

import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/core/services/secure_storage_service.dart';
import 'package:smart_univ/domain/entities/user_profile.dart';
import 'package:smart_univ/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const _profileKey = 'auth_profile';

  // Mock credentials — replace with real API call in a later sprint.
  static const _mockEmail = 'hacen@university.dz';
  static const _mockPassword = 'password123';
  static const _mockUser = UserProfile(
    id: 'u1',
    fullName: 'Hacen Bensaad',
    email: _mockEmail,
    studentId: '20210001',
    department: 'Computer Science',
  );

  final SecureStorageService _storage;

  AuthRepositoryImpl(this._storage);

  @override
  Future<Either<AppException, UserProfile>> signUp({
    required String fullName,
    required String studentId,
    required String department,
    required String email,
    required String password,
  }) async {
    if (password.length < 8) {
      return left(const AuthException('Password must be at least 8 characters'));
    }
    final profile = UserProfile(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName.trim(),
      email: email.trim(),
      studentId: studentId.trim(),
      department: department.trim(),
    );
    final expiry = DateTime.now().add(const Duration(hours: 1));
    await Future.wait([
      _storage.saveToken(SecureStorageService.accessKey, 'mock_access_${profile.id}'),
      _storage.saveToken(SecureStorageService.refreshKey, 'mock_refresh_${profile.id}'),
      _storage.saveToken(SecureStorageService.expiryKey, expiry.toIso8601String()),
      _storage.saveToken(_profileKey, _encodeProfile(profile)),
      _storage.saveToken(
        SecureStorageService.credentialsKey,
        jsonEncode({'email': email.trim(), 'password': password}),
      ),
    ]);
    return right(profile);
  }

  @override
  Future<Either<AppException, UserProfile>> signIn({
    required String email,
    required String password,
  }) async {
    final storedCreds = await _storage.readToken(SecureStorageService.credentialsKey);
    if (storedCreds != null) {
      final creds = jsonDecode(storedCreds) as Map<String, dynamic>;
      if (email.trim() != creds['email'] || password != creds['password']) {
        return left(const AuthException('Invalid email or password'));
      }
      final raw = await _storage.readToken(_profileKey);
      if (raw == null) return left(const AuthException('Invalid email or password'));
      final profile = _decodeProfile(raw);
      final expiry = DateTime.now().add(const Duration(hours: 1));
      await Future.wait([
        _storage.saveToken(SecureStorageService.accessKey, 'mock_access_${profile.id}'),
        _storage.saveToken(SecureStorageService.refreshKey, 'mock_refresh_${profile.id}'),
        _storage.saveToken(SecureStorageService.expiryKey, expiry.toIso8601String()),
      ]);
      return right(profile);
    }
    // Fallback: demo credentials
    if (email.trim() != _mockEmail || password != _mockPassword) {
      return left(const AuthException('Invalid email or password'));
    }
    final expiry = DateTime.now().add(const Duration(hours: 1));
    await Future.wait([
      _storage.saveToken(SecureStorageService.accessKey, 'mock_access_${_mockUser.id}'),
      _storage.saveToken(SecureStorageService.refreshKey, 'mock_refresh_${_mockUser.id}'),
      _storage.saveToken(SecureStorageService.expiryKey, expiry.toIso8601String()),
      _storage.saveToken(_profileKey, _encodeProfile(_mockUser)),
    ]);
    return right(_mockUser);
  }

  @override
  Future<Either<AppException, Unit>> signOut() async {
    // Clear session tokens only — preserve profile + credentials for biometric re-auth.
    await Future.wait([
      _storage.deleteToken(SecureStorageService.accessKey),
      _storage.deleteToken(SecureStorageService.refreshKey),
      _storage.deleteToken(SecureStorageService.expiryKey),
    ]);
    return right(unit);
  }

  @override
  Future<Either<AppException, UserProfile?>> getCurrentUser() async {
    if (!await isLoggedIn()) return right(null);
    final raw = await _storage.readToken(_profileKey);
    if (raw == null) return right(null);
    return right(_decodeProfile(raw));
  }

  @override
  Future<Either<AppException, UserProfile?>> getStoredProfile() async {
    final raw = await _storage.readToken(_profileKey);
    if (raw == null) return right(null);
    return right(_decodeProfile(raw));
  }

  @override
  Future<Either<AppException, Unit>> restoreSession(UserProfile profile) async {
    final expiry = DateTime.now().add(const Duration(hours: 1));
    await Future.wait([
      _storage.saveToken(SecureStorageService.accessKey, 'mock_access_${profile.id}'),
      _storage.saveToken(SecureStorageService.refreshKey, 'mock_refresh_${profile.id}'),
      _storage.saveToken(SecureStorageService.expiryKey, expiry.toIso8601String()),
    ]);
    return right(unit);
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _storage.readToken(SecureStorageService.accessKey);
    return token != null;
  }

  @override
  Future<bool> isSessionValid() async {
    final raw = await _storage.readToken(SecureStorageService.expiryKey);
    if (raw == null) return false;
    final expiry = DateTime.tryParse(raw);
    return expiry != null && expiry.isAfter(DateTime.now());
  }

  @override
  Future<bool> refreshSession() async {
    // TODO: exchange refreshKey for a new access token via the auth server.
    // For now, extend the mock expiry to simulate a successful silent refresh.
    final refreshToken = await _storage.readToken(SecureStorageService.refreshKey);
    if (refreshToken == null) return false;
    final newExpiry = DateTime.now().add(const Duration(hours: 1));
    await _storage.saveToken(SecureStorageService.expiryKey, newExpiry.toIso8601String());
    return true;
  }

  // ── helpers ──────────────────────────────────────────────────────────────────

  static String _encodeProfile(UserProfile p) => jsonEncode({
        'id': p.id,
        'fullName': p.fullName,
        'email': p.email,
        'studentId': p.studentId,
        'department': p.department,
      });

  static UserProfile _decodeProfile(String raw) {
    final m = jsonDecode(raw) as Map<String, dynamic>;
    return UserProfile(
      id: m['id'] as String,
      fullName: m['fullName'] as String,
      email: m['email'] as String,
      studentId: m['studentId'] as String,
      department: m['department'] as String,
    );
  }
}
