part of 'events_bloc.dart';

sealed class EventsState extends Equatable {
  const EventsState();

  @override
  List<Object?> get props => [];
}

final class EventsInitial extends EventsState {}

final class EventsLoading extends EventsState {}

final class EventsLoaded extends EventsState {
  final List<Event> events;

  const EventsLoaded(this.events);

  @override
  List<Object?> get props => [events];
}

final class EventsFailure extends EventsState {
  final String message;

  const EventsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
