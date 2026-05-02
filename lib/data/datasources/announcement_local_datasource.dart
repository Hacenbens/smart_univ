import 'package:smart_univ/data/models/announcement_dto.dart';

abstract interface class AnnouncementLocalDataSource {
  Future<List<AnnouncementDto>> getCachedAnnouncements();
  Future<void> cacheAnnouncements(List<AnnouncementDto> items);
  Stream<List<AnnouncementDto>> watchAnnouncements();
}
