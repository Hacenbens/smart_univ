part of 'events_bloc.dart';

sealed class EventsEvent extends Equatable {
  const EventsEvent();

  @override
  List<Object?> get props => [];
}

final class EventsRequested extends EventsEvent {
  const EventsRequested();
}

final class AttachPhotoRequested extends EventsEvent {
  final String eventId;
  final PhotoSource source;

  const AttachPhotoRequested({required this.eventId, required this.source});

  @override
  List<Object?> get props => [eventId, source];
}
