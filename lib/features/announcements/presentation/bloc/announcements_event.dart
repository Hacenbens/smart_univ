part of 'announcements_bloc.dart';

sealed class AnnouncementsEvent extends Equatable {
  const AnnouncementsEvent();

  @override
  List<Object?> get props => [];
}

final class AnnouncementsRequested extends AnnouncementsEvent {
  const AnnouncementsRequested();
}
