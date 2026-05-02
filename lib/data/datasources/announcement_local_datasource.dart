import 'package:smart_univ/data/models/announcement_dto.dart';

abstract interface class AnnouncementLocalDataSource {
  Future<List<AnnouncementDto>> getCachedAnnouncements();
  Future<void> cacheAnnouncements(List<AnnouncementDto> items);
  Stream<List<AnnouncementDto>> watchAnnouncements();
  /// Returns the oldest cachedAt across all rows, or null if the cache is empty.
  Future<DateTime?> getLastCachedAt();
}
