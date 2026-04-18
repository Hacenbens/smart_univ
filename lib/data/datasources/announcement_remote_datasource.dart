import 'package:smart_univ/data/models/announcement_dto.dart';

abstract interface class AnnouncementRemoteDataSource {
  Future<List<AnnouncementDto>> getAnnouncements();
}
