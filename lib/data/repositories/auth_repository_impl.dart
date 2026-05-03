import 'dart:convert';

import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/core/services/secure_storage_service.dart';
import 'package:smart_univ/domain/entities/user_profile.dart';
import 'package:smart_univ/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  // Private key — not a token, only AuthRepositoryImpl touches it.
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
  Future<Either<AppException, UserProfile>> signIn({
    required String email,
    required String password,
  }) async {
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
    // TODO: call server-side revoke endpoint before clearing local storage.
    await _storage.deleteAll();
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
