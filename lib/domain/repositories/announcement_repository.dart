import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/domain/entities/announcement.dart';

abstract interface class AnnouncementRepository {
  Future<Either<AppException, List<Announcement>>> getAnnouncements();
  Future<Either<AppException, Announcement>> getAnnouncementById(String id);
}
