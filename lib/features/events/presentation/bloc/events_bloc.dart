import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_univ/core/usecases/use_case.dart';
import 'package:smart_univ/domain/entities/event.dart';
import 'package:smart_univ/domain/usecases/get_events_use_case.dart';

part 'events_event.dart';
part 'events_state.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final GetEventsUseCase _getEvents;

  EventsBloc(this._getEvents) : super(EventsInitial()) {
    on<EventsRequested>(_onRequested);
  }

  Future<void> _onRequested(
    EventsRequested event,
    Emitter<EventsState> emit,
  ) async {
    emit(EventsLoading());
    final result = await _getEvents(const NoParams());
    result.fold(
      (failure) => emit(EventsFailure(failure.message)),
      (events) => emit(EventsLoaded(events)),
    );
  }
}
