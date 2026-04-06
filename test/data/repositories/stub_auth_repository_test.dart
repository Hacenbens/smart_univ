import 'package:flutter_test/flutter_test.dart';
import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/data/repositories/stub_auth_repository.dart';
import 'package:smart_univ/domain/entities/user_profile.dart';

void main() {
  late StubAuthRepository repo;

  setUp(() => repo = StubAuthRepository());

  group('StubAuthRepository', () {
    group('getCurrentUser()', () {
      test('returns Right(null) when not signed in', () async {
        final result = await repo.getCurrentUser();
        expect(result.isRight, isTrue);
        expect((result as Right<AppException, UserProfile?>).value, isNull);
      });
    });

    group('signIn()', () {
      test('returns Right(UserProfile) with correct credentials', () async {
        final result = await repo.signIn(
          email: 'hacen@university.dz',
          password: 'password123',
        );
        expect(result.isRight, isTrue);
        final user = (result as Right<AppException, UserProfile>).value;
        expect(user.email, 'hacen@university.dz');
        expect(user.department, 'Computer Science');
      });

      test('returns Left(AuthException) with wrong password', () async {
        final result = await repo.signIn(
          email: 'hacen@university.dz',
          password: 'wrong',
        );
        expect(result.isLeft, isTrue);
        expect((result as Left).value, isA<AuthException>());
      });

      test('returns Left(AuthException) with unknown email', () async {
        final result = await repo.signIn(
          email: 'unknown@university.dz',
          password: 'password123',
        );
        expect(result.isLeft, isTrue);
      });

      test('getCurrentUser() returns user after sign in', () async {
        await repo.signIn(
          email: 'hacen@university.dz',
          password: 'password123',
        );
        final result = await repo.getCurrentUser();
        expect((result as Right).value, isNotNull);
      });
    });

    group('signOut()', () {
      test('returns Right(unit)', () async {
        await repo.signIn(
          email: 'hacen@university.dz',
          password: 'password123',
        );
        final result = await repo.signOut();
        expect(result.isRight, isTrue);
      });

      test('getCurrentUser() returns null after sign out', () async {
        await repo.signIn(
          email: 'hacen@university.dz',
          password: 'password123',
        );
        await repo.signOut();
        final result = await repo.getCurrentUser();
        expect((result as Right).value, isNull);
      });
    });
  });
}
