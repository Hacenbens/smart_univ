import 'package:fpdart/fpdart.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/domain/entities/user_profile.dart';
import 'package:smart_univ/domain/repositories/auth_repository.dart';

class StubAuthRepository implements AuthRepository {
  static const _mockUser = UserProfile(
    id: 'u1',
    fullName: 'Hacen Bensaci',
    email: 'hacen@university.dz',
    studentId: '20210001',
    department: 'Computer Science',
  );

  UserProfile? _currentUser;

  @override
  Future<Either<AppException, UserProfile>> signIn({
    required String email,
    required String password,
  }) async {
    if (email == _mockUser.email && password == 'password123') {
      _currentUser = _mockUser;
      return right(_mockUser);
    }
    return left(const AuthException('Invalid credentials'));
  }

  @override
  Future<Either<AppException, Unit>> signOut() async {
    _currentUser = null;
    return right(unit);
  }

  @override
  Future<Either<AppException, UserProfile?>> getCurrentUser() async =>
      right(_currentUser);
}
