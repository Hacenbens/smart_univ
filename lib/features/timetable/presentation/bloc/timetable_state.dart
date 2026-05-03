part of 'timetable_bloc.dart';

sealed class TimetableState extends Equatable {
  const TimetableState();

  @override
  List<Object?> get props => [];
}

final class TimetableInitial extends TimetableState {
  const TimetableInitial();
}

final class TimetableLoading extends TimetableState {
  const TimetableLoading();
}

final class TimetableLoaded extends TimetableState {
  final List<TimetableItem> items;
  const TimetableLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

final class TimetableFailure extends TimetableState {
  final String message;
  const TimetableFailure(this.message);

  @override
  List<Object?> get props => [message];
}
