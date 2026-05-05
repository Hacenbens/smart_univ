import 'package:flutter/widgets.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_univ/core/usecases/use_case.dart';
import 'package:smart_univ/domain/entities/announcement.dart';
import 'package:smart_univ/domain/usecases/get_announcements_use_case.dart';

part 'announcements_event.dart';
part 'announcements_state.dart';

class AnnouncementsBloc extends Bloc<AnnouncementsEvent, AnnouncementsState>
    with WidgetsBindingObserver {
  static const refreshThreshold = Duration(minutes: 15);

  final GetAnnouncementsUseCase _getAnnouncements;

  /// Timestamp of the last successful fetch. Exposed for testing.
  @visibleForTesting
  DateTime? lastFetchedAt;

  AnnouncementsBloc(this._getAnnouncements) : super(AnnouncementsInitial()) {
    WidgetsBinding.instance.addObserver(this);
    on<AnnouncementsRequested>(_onRequested);
    on<AppLifecycleRefreshRequested>(_onLifecycleRefresh);
    on<AnnouncementsRefreshRequested>(_onShakeRefresh);
    on<AnnouncementFilterChanged>(_onFilterChanged);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final last = lastFetchedAt;
      final isStale =
          last == null || DateTime.now().difference(last) > refreshThreshold;
      if (isStale) add(const AppLifecycleRefreshRequested());
    }
  }

  Future<void> _onRequested(
    AnnouncementsRequested event,
    Emitter<AnnouncementsState> emit,
  ) =>
      _fetch(emit);

  Future<void> _onLifecycleRefresh(
    AppLifecycleRefreshRequested event,
    Emitter<AnnouncementsState> emit,
  ) =>
      _fetch(emit);

  Future<void> _onShakeRefresh(
    AnnouncementsRefreshRequested event,
    Emitter<AnnouncementsState> emit,
  ) =>
      _fetch(emit);

  Future<void> _fetch(Emitter<AnnouncementsState> emit) async {
    final previousFilter = state is AnnouncementsLoaded
        ? (state as AnnouncementsLoaded).activeFilter
        : AnnouncementFilter.all;
    emit(AnnouncementsLoading());
    final result = await _getAnnouncements(const NoParams());
    result.fold(
      (failure) => emit(AnnouncementsFailure(failure.message)),
      (announcements) {
        lastFetchedAt = DateTime.now();
        emit(AnnouncementsLoaded(announcements, activeFilter: previousFilter));
      },
    );
  }

  void _onFilterChanged(
    AnnouncementFilterChanged event,
    Emitter<AnnouncementsState> emit,
  ) {
    final current = state;
    if (current is AnnouncementsLoaded) {
      emit(current.copyWithFilter(event.filter));
    }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}
