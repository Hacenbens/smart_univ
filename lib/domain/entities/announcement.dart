import 'package:equatable/equatable.dart';

enum AnnouncementCategory { general, academic, campusLife, services }

class Announcement extends Equatable {
  final String id;
  final String title;
  final String body;
  final DateTime publishedAt;
  final String authorName;
  final AnnouncementCategory category;
  final bool isPinned;

  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.publishedAt,
    required this.authorName,
    this.category = AnnouncementCategory.general,
    this.isPinned = false,
  });

  @override
  List<Object?> get props => [id, title, body, publishedAt, authorName, category, isPinned];
}
