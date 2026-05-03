part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

final class _HomeShakeReceived extends HomeEvent {
  const _HomeShakeReceived();
}

final class _HomeAppResumed extends HomeEvent {
  const _HomeAppResumed();
}
