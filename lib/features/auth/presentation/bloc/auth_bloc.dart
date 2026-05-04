import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_univ/core/services/notification_service.dart';
import 'package:smart_univ/domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthBlocState> {
  final AuthRepository _repository;
  final NotificationService _notif;

  AuthBloc(this._repository, this._notif) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    final loggedIn = await _repository.isLoggedIn();
    emit(loggedIn ? const AuthAuthenticated() : const AuthUnauthenticated());
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _repository.signUp(
      fullName: event.fullName,
      studentId: event.studentId,
      department: event.department,
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(const AuthAuthenticated()),
    );
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _repository.signIn(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(const AuthAuthenticated()),
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    await _notif.cancelAll();
    await _repository.signOut();
    emit(const AuthUnauthenticated());
  }
}
