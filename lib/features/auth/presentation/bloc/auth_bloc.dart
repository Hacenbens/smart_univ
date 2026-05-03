import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_univ/core/services/notification_service.dart';
import 'package:smart_univ/domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthBlocState> {
  // ignore: unused_field — will be used in Week 2
  final AuthRepository _repository;
  final NotificationService _notif;

  AuthBloc(this._repository, this._notif) : super(AuthInitial()) {
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    // TODO(week-2): call _repository.signIn and emit AuthAuthenticated/AuthFailure
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    await _notif.cancelAll();
    emit(AuthUnauthenticated());
  }
}
