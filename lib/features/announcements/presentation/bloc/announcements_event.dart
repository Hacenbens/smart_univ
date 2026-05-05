part of 'announcements_bloc.dart';

sealed class AnnouncementsEvent extends Equatable {
  const AnnouncementsEvent();

  @override
  List<Object?> get props => [];
}

final class AnnouncementsRequested extends AnnouncementsEvent {
  const AnnouncementsRequested();
}

/// Dispatched automatically by the bloc when the app resumes and the last
/// fetch is older than [AnnouncementsBloc.refreshThreshold].
final class AppLifecycleRefreshRequested extends AnnouncementsEvent {
  const AppLifecycleRefreshRequested();
}

/// Dispatched internally when a shake gesture is detected.
final class AnnouncementsRefreshRequested extends AnnouncementsEvent {
  const AnnouncementsRefreshRequested();
}

final class AnnouncementFilterChanged extends AnnouncementsEvent {
  final AnnouncementFilter filter;

  const AnnouncementFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}
