part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Emitted on every detected shake. The [count] increments with each shake
/// so consecutive shakes produce distinct states and BlocListeners always fire.
final class HomeShakeDetected extends HomeState {
  final int count;
  const HomeShakeDetected(this.count);

  @override
  List<Object?> get props => [count];
}
