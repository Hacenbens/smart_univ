import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/domain/entities/user_profile.dart';

abstract interface class AuthRepository {
  Future<Either<AppException, UserProfile>> signUp({
    required String fullName,
    required String studentId,
    required String department,
    required String email,
    required String password,
  });
  Future<Either<AppException, UserProfile>> signIn({
    required String email,
    required String password,
  });
  Future<Either<AppException, Unit>> signOut();
  Future<Either<AppException, UserProfile?>> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<bool> isSessionValid();
  Future<bool> refreshSession();
}
