import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_univ/domain/repositories/event_repository.dart';

part 'events_event.dart';
part 'events_state.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  // ignore: unused_field — will be used in Week 2
  final EventRepository _repository;

  EventsBloc(this._repository) : super(EventsInitial()) {
    on<EventsRequested>(_onRequested);
  }

  Future<void> _onRequested(
    EventsRequested event,
    Emitter<EventsState> emit,
  ) async {
    // TODO(week-2): fetch from repository and emit loaded/error states
  }
}
