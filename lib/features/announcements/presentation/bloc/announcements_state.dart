part of 'announcements_bloc.dart';

sealed class AnnouncementsState extends Equatable {
  const AnnouncementsState();

  @override
  List<Object?> get props => [];
}

final class AnnouncementsInitial extends AnnouncementsState {}
