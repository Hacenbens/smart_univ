import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_univ/domain/entities/announcement.dart';
import 'package:smart_univ/domain/usecases/get_announcements_use_case.dart';
import 'package:smart_univ/core/usecases/use_case.dart';

part 'announcements_event.dart';
part 'announcements_state.dart';

class AnnouncementsBloc extends Bloc<AnnouncementsEvent, AnnouncementsState> {
  final GetAnnouncementsUseCase _getAnnouncements;

  AnnouncementsBloc(this._getAnnouncements) : super(AnnouncementsInitial()) {
    on<AnnouncementsRequested>(_onRequested);
  }

  Future<void> _onRequested(
    AnnouncementsRequested event,
    Emitter<AnnouncementsState> emit,
  ) async {
    emit(AnnouncementsLoading());
    final result = await _getAnnouncements(const NoParams());
    result.fold(
      (failure) => emit(AnnouncementsFailure(failure.message)),
      (announcements) => emit(AnnouncementsLoaded(announcements)),
    );
  }
}
