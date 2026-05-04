part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthSignUpRequested extends AuthEvent {
  final String fullName;
  final String studentId;
  final String department;
  final String email;
  final String password;

  const AuthSignUpRequested({
    required this.fullName,
    required this.studentId,
    required this.department,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [fullName, studentId, department, email, password];
}

final class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

final class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}
