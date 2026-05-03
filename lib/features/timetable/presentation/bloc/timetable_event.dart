part of 'timetable_bloc.dart';

sealed class TimetableEvent extends Equatable {
  const TimetableEvent();

  @override
  List<Object?> get props => [];
}

final class TimetableRequested extends TimetableEvent {
  const TimetableRequested();
}
