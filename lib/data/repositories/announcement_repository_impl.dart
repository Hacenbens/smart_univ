import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/core/services/connectivity_service.dart';
import 'package:smart_univ/data/datasources/announcement_local_datasource.dart';
import 'package:smart_univ/data/datasources/announcement_remote_datasource.dart';
import 'package:smart_univ/domain/entities/announcement.dart';
import 'package:smart_univ/domain/repositories/announcement_repository.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  static const _ttl = Duration(minutes: 15);

  final AnnouncementRemoteDataSource _remote;
  final AnnouncementLocalDataSource _local;
  final ConnectivityService _connectivity;

  AnnouncementRepositoryImpl(this._remote, this._local, this._connectivity);

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

    // (3) No connection — serve stale cache or fail fast.
    if (!await _connectivity.isConnected()) {
      if (cachedAt != null) {
        final cached = await _local.getCachedAnnouncements();
        if (cached.isNotEmpty) {
          return right(cached.map((dto) => dto.toDomain()).toList());
        }
      }
      return left(const NetworkException('No internet connection and no cached data'));
    }

    // (4) Cache is stale or empty and connected — fetch from remote.
    try {
      final dtos = await _remote.getAnnouncements();
      await _local.cacheAnnouncements(dtos);
      return right(dtos.map((dto) => dto.toDomain()).toList());
    } on AppException catch (e) {
      // (5) Network failed mid-flight — serve stale cache if available.
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
