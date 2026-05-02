part of 'announcements_bloc.dart';

sealed class AnnouncementsState extends Equatable {
  const AnnouncementsState();

  @override
  List<Object?> get props => [];
}

final class AnnouncementsInitial extends AnnouncementsState {}

final class AnnouncementsLoading extends AnnouncementsState {}

final class AnnouncementsLoaded extends AnnouncementsState {
  final List<Announcement> announcements;

  const AnnouncementsLoaded(this.announcements);

  @override
  List<Object?> get props => [announcements];
}

final class AnnouncementsFailure extends AnnouncementsState {
  final String message;

  const AnnouncementsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
