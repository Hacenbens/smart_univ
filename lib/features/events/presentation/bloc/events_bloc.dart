import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_univ/core/usecases/use_case.dart';
import 'package:smart_univ/domain/entities/event.dart';
import 'package:smart_univ/domain/repositories/event_repository.dart';
import 'package:smart_univ/domain/usecases/attach_photo_use_case.dart';
import 'package:smart_univ/domain/usecases/get_events_use_case.dart';

part 'events_event.dart';
part 'events_state.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final GetEventsUseCase _getEvents;
  final AttachPhotoUseCase _attachPhoto;
  final EventRepository _eventRepository;

  EventsBloc(this._getEvents, this._attachPhoto, this._eventRepository)
      : super(EventsInitial()) {
    on<EventsRequested>(_onRequested);
    on<AttachPhotoRequested>(_onAttachPhotoRequested);
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

  Future<void> _onAttachPhotoRequested(
    AttachPhotoRequested event,
    Emitter<EventsState> emit,
  ) async {
    final current = state;
    if (current is! EventsLoaded) return;

    final pickResult = await _attachPhoto(AttachPhotoParams(event.source));
    await pickResult.fold(
      (failure) async {
        emit(EventsLoaded(current.events, photoAttachError: failure.message));
      },
      (path) async {
        if (path == null) return; // user cancelled
        final saveResult =
            await _eventRepository.updateEventPhoto(event.eventId, path);
        saveResult.fold(
          (failure) =>
              emit(EventsLoaded(current.events, photoAttachError: failure.message)),
          (_) => emit(
            EventsLoaded(
              current.events
                  .map((e) =>
                      e.id == event.eventId ? e.copyWith(photoPath: path) : e)
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}
