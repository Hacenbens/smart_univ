import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_univ/core/services/notification_service.dart';
import 'package:smart_univ/core/usecases/use_case.dart';
import 'package:smart_univ/domain/entities/timetable_item.dart';
import 'package:smart_univ/domain/usecases/get_timetable_use_case.dart';
import 'package:smart_univ/domain/usecases/schedule_reminders_use_case.dart';

part 'timetable_event.dart';
part 'timetable_state.dart';

class TimetableBloc extends Bloc<TimetableEvent, TimetableState> {
  final GetTimetableUseCase _getTimetable;
  final ScheduleRemindersUseCase _scheduleReminders;
  final NotificationService _notif;

  TimetableBloc(this._getTimetable, this._scheduleReminders, this._notif)
      : super(const TimetableInitial()) {
    on<TimetableRequested>(_onRequested);
    on<TimetableItemDeleted>(_onDeleted);
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

  Future<void> _onDeleted(
    TimetableItemDeleted event,
    Emitter<TimetableState> emit,
  ) async {
    await _notif.cancel(int.parse(event.item.id)); // cancel before removing
    final current = state;
    if (current is TimetableLoaded) {
      emit(TimetableLoaded(
        current.items.where((i) => i.id != event.item.id).toList(),
      ));
    }
  }
}
