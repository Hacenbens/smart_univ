import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_univ/core/usecases/use_case.dart';
import 'package:smart_univ/domain/entities/timetable_item.dart';
import 'package:smart_univ/domain/usecases/get_timetable_use_case.dart';
import 'package:smart_univ/domain/usecases/schedule_reminders_use_case.dart';

part 'timetable_event.dart';
part 'timetable_state.dart';

class TimetableBloc extends Bloc<TimetableEvent, TimetableState> {
  final GetTimetableUseCase _getTimetable;
  final ScheduleRemindersUseCase _scheduleReminders;

  TimetableBloc(this._getTimetable, this._scheduleReminders)
      : super(const TimetableInitial()) {
    on<TimetableRequested>(_onRequested);
  }

  Future<void> _onRequested(
    TimetableRequested event,
    Emitter<TimetableState> emit,
  ) async {
    emit(const TimetableLoading());
    final result = await _getTimetable(const NoParams());
    result.fold(
      (failure) => emit(TimetableFailure(failure.message)),
      (items) {
        emit(TimetableLoaded(items));
        _scheduleReminders(const NoParams());
      },
    );
  }
}
