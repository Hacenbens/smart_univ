import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_univ/core/services/biometric_service.dart';
import 'package:smart_univ/core/services/notification_service.dart';
import 'package:smart_univ/domain/entities/user_profile.dart';
import 'package:smart_univ/domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthBlocState> {
  final AuthRepository _repository;
  final NotificationService _notif;
  final BiometricService _biometric;

  AuthBloc(this._repository, this._notif, this._biometric) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthBiometricRequested>(_onBiometricRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    final loggedIn = await _repository.isLoggedIn();
    if (!loggedIn) {
      emit(const AuthUnauthenticated());
      return;
    }
    final result = await _repository.getCurrentUser();
    final user = result.fold((_) => null, (u) => u);
    emit(AuthAuthenticated(user: user));
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
      (user) => emit(AuthAuthenticated(user: user)),
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
      (user) => emit(AuthAuthenticated(user: user)),
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

  Future<void> _onBiometricRequested(
    AuthBiometricRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    final available = await _biometric.isAvailable();
    if (!available) {
      emit(const AuthFailure('No biometrics enrolled on this device'));
      return;
    }
    emit(const AuthLoading());
    final authenticated = await _biometric.authenticate();
    if (!authenticated) {
      emit(const AuthFailure('Biometric authentication failed'));
      return;
    }
    final result = await _repository.getStoredProfile();
    await result.fold(
      (failure) async => emit(AuthFailure(failure.message)),
      (user) async {
        if (user == null) {
          emit(const AuthFailure('Sign in with email first to enable biometrics'));
          return;
        }
        await _repository.restoreSession(user);
        emit(AuthAuthenticated(user: user));
      },
    );
  }
}
