import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_univ/domain/repositories/announcement_repository.dart';

part 'announcements_event.dart';
part 'announcements_state.dart';

class AnnouncementsBloc extends Bloc<AnnouncementsEvent, AnnouncementsState> {
  // ignore: unused_field — will be used in Week 2
  final AnnouncementRepository _repository;

  AnnouncementsBloc(this._repository) : super(AnnouncementsInitial()) {
    on<AnnouncementsRequested>(_onRequested);
  }

  Future<void> _onRequested(
    AnnouncementsRequested event,
    Emitter<AnnouncementsState> emit,
  ) async {
    // TODO(week-2): fetch from repository and emit loaded/error states
  }
}
