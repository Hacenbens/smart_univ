import 'package:fpdart/fpdart.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/domain/entities/announcement.dart';
import 'package:smart_univ/domain/repositories/announcement_repository.dart';

class StubAnnouncementRepository implements AnnouncementRepository {
  static final _announcements = [
    Announcement(
      id: '1',
      title: 'Campus Wi-Fi Maintenance',
      body: 'The campus Wi-Fi will be down for maintenance on Saturday from 2–4 AM.',
      publishedAt: DateTime(2026, 4, 5),
      authorName: 'IT Department',
    ),
    Announcement(
      id: '2',
      title: 'Library Extended Hours',
      body: 'The library will be open until midnight during exam week.',
      publishedAt: DateTime(2026, 4, 6),
      authorName: 'Library Services',
    ),
  ];

  @override
  Future<Either<AppException, List<Announcement>>> getAnnouncements() async =>
      right(_announcements);

  @override
  Future<Either<AppException, Announcement>> getAnnouncementById(String id) async {
    final match = _announcements.where((a) => a.id == id).toList();
    if (match.isEmpty) return left(const CacheException('Announcement not found'));
    return right(match.first);
  }
}
