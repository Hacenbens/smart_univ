import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/data/datasources/announcement_local_datasource.dart';
import 'package:smart_univ/data/datasources/announcement_remote_datasource.dart';
import 'package:smart_univ/domain/entities/announcement.dart';
import 'package:smart_univ/domain/repositories/announcement_repository.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  static const _ttl = Duration(minutes: 15);

  final AnnouncementRemoteDataSource _remote;
  final AnnouncementLocalDataSource _local;

  AnnouncementRepositoryImpl(this._remote, this._local);

  @override
  Future<Either<AppException, List<Announcement>>> getAnnouncements() async {
    // (1) Read cachedAt from local.
    final cachedAt = await _local.getLastCachedAt();
    final cacheAge =
        cachedAt == null ? null : DateTime.now().difference(cachedAt);

    // (2) Cache is fresh — skip the network entirely.
    if (cacheAge != null && cacheAge < _ttl) {
      final cached = await _local.getCachedAnnouncements();
      return right(cached.map((dto) => dto.toDomain()).toList());
    }

    // (3) Cache is stale or empty — fetch from remote.
    try {
      final dtos = await _remote.getAnnouncements();
      await _local.cacheAnnouncements(dtos);
      return right(dtos.map((dto) => dto.toDomain()).toList());
    } on AppException catch (e) {
      // (4) Network failed — serve stale cache if available.
      if (cachedAt != null) {
        final cached = await _local.getCachedAnnouncements();
        if (cached.isNotEmpty) {
          return right(cached.map((dto) => dto.toDomain()).toList());
        }
      }
      return left(e);
    }
  }

  @override
  Future<Either<AppException, Announcement>> getAnnouncementById(
      String id) async {
    final result = await getAnnouncements();
    return result.fold(
      left,
      (list) {
        final match = list.where((a) => a.id == id);
        if (match.isEmpty) {
          return left(const CacheException('Announcement not found'));
        }
        return right(match.first);
      },
    );
  }
}
