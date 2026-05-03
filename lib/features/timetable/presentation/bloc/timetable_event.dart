part of 'timetable_bloc.dart';

sealed class TimetableEvent extends Equatable {
  const TimetableEvent();

  @override
  List<Object?> get props => [];
}

final class TimetableRequested extends TimetableEvent {
  const TimetableRequested();
}

final class TimetableItemDeleted extends TimetableEvent {
  final TimetableItem item;
  const TimetableItemDeleted(this.item);

  @override
  List<Object?> get props => [item];
}
