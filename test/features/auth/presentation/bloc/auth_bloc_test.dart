import 'package:flutter_test/flutter_test.dart';
import 'package:smart_univ/data/repositories/stub_auth_repository.dart';
import 'package:smart_univ/features/auth/presentation/bloc/auth_bloc.dart';

void main() {
  late AuthBloc bloc;

  setUp(() {
    bloc = AuthBloc(StubAuthRepository());
  });

  tearDown(() => bloc.close());

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(bloc.state, isA<AuthInitial>());
    });

    test('adding AuthSignInRequested does not throw', () {
      expect(
        () => bloc.add(const AuthSignInRequested(
          email: 'test@test.com',
          password: 'pass',
        )),
        returnsNormally,
      );
    });

    test('adding AuthSignOutRequested does not throw', () {
      expect(
        () => bloc.add(const AuthSignOutRequested()),
        returnsNormally,
      );
    });

    test('state remains AuthInitial after sign-in event (stub)', () async {
      bloc.add(const AuthSignInRequested(
        email: 'hacen@university.dz',
        password: 'password123',
      ));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state, isA<AuthInitial>());
    });

    group('AuthSignInRequested', () {
      test('holds email and password in props', () {
        const event = AuthSignInRequested(
          email: 'a@b.com',
          password: 'secret',
        );
        expect(event.props, ['a@b.com', 'secret']);
      });
    });

    group('AuthBlocState subtypes', () {
      test('AuthAuthenticated is an AuthBlocState', () {
        expect(const AuthAuthenticated(), isA<AuthBlocState>());
      });

      test('AuthUnauthenticated is an AuthBlocState', () {
        expect(const AuthUnauthenticated(), isA<AuthBlocState>());
      });
    });
  });
}
