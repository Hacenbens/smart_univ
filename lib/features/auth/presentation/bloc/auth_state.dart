part of 'auth_bloc.dart';

sealed class AuthBlocState extends Equatable {
  const AuthBlocState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthBlocState {}

final class AuthAuthenticated extends AuthBlocState {
  const AuthAuthenticated();
}

final class AuthUnauthenticated extends AuthBlocState {
  const AuthUnauthenticated();
}
