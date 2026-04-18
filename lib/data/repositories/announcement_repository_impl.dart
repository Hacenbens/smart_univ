import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/data/datasources/announcement_remote_datasource.dart';
import 'package:smart_univ/domain/entities/announcement.dart';
import 'package:smart_univ/domain/repositories/announcement_repository.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final AnnouncementRemoteDataSource _dataSource;

  AnnouncementRepositoryImpl(this._dataSource);

  @override
  Future<Either<AppException, List<Announcement>>> getAnnouncements() async {
    try {
      final dtos = await _dataSource.getAnnouncements();
      return right(dtos.map((dto) => dto.toDomain()).toList());
    } on AppException catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<AppException, Announcement>> getAnnouncementById(
      String id) async {
    try {
      final dtos = await _dataSource.getAnnouncements();
      final match = dtos.where((dto) => dto.id.toString() == id);
      if (match.isEmpty) return left(const CacheException('Announcement not found'));
      return right(match.first.toDomain());
    } on AppException catch (e) {
      return left(e);
    }
  }
}
