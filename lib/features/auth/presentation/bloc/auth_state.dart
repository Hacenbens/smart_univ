part of 'auth_bloc.dart';

sealed class AuthBlocState extends Equatable {
  const AuthBlocState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthBlocState {}

final class AuthLoading extends AuthBlocState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthBlocState {
  const AuthAuthenticated();
}

final class AuthUnauthenticated extends AuthBlocState {
  const AuthUnauthenticated();
}

final class AuthFailure extends AuthBlocState {
  final String message;
  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
