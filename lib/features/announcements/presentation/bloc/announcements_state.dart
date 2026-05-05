part of 'announcements_bloc.dart';

enum AnnouncementFilter { all, pinned, academic, campusLife, services }

sealed class AnnouncementsState extends Equatable {
  const AnnouncementsState();

  @override
  List<Object?> get props => [];
}

final class AnnouncementsInitial extends AnnouncementsState {}

final class AnnouncementsLoading extends AnnouncementsState {}

final class AnnouncementsLoaded extends AnnouncementsState {
  final List<Announcement> allAnnouncements;
  final AnnouncementFilter activeFilter;

  const AnnouncementsLoaded(
    this.allAnnouncements, {
    this.activeFilter = AnnouncementFilter.all,
  });

  List<Announcement> get filtered => switch (activeFilter) {
        AnnouncementFilter.all => allAnnouncements,
        AnnouncementFilter.pinned =>
          allAnnouncements.where((a) => a.isPinned).toList(),
        AnnouncementFilter.academic => allAnnouncements
            .where((a) => a.category == AnnouncementCategory.academic)
            .toList(),
        AnnouncementFilter.campusLife => allAnnouncements
            .where((a) => a.category == AnnouncementCategory.campusLife)
            .toList(),
        AnnouncementFilter.services => allAnnouncements
            .where((a) => a.category == AnnouncementCategory.services)
            .toList(),
      };

  AnnouncementsLoaded copyWithFilter(AnnouncementFilter filter) =>
      AnnouncementsLoaded(allAnnouncements, activeFilter: filter);

  @override
  List<Object?> get props => [allAnnouncements, activeFilter];
}

final class AnnouncementsFailure extends AnnouncementsState {
  final String message;

  const AnnouncementsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
