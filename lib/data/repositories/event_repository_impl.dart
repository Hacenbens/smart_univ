import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/data/datasources/event_local_datasource.dart';
import 'package:smart_univ/data/datasources/event_remote_datasource.dart';
import 'package:smart_univ/domain/entities/event.dart';
import 'package:smart_univ/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  static const _ttl = Duration(minutes: 15);

  final EventRemoteDataSource _remote;
  final EventLocalDataSource _local;

  EventRepositoryImpl(this._remote, this._local);

  @override
  Future<Either<AppException, List<Event>>> getEvents() async {
    // (1) Read cachedAt from local.
    final cachedAt = await _local.getLastCachedAt();
    final cacheAge =
        cachedAt == null ? null : DateTime.now().difference(cachedAt);

    // (2) Cache is fresh — skip the network entirely.
    if (cacheAge != null && cacheAge < _ttl) {
      final cached = await _local.getCachedEvents();
      return right(cached.map((dto) => dto.toDomain()).toList());
    }

    // (3) Cache is stale or empty — fetch from remote.
    try {
      final dtos = await _remote.getEvents();
      await _local.cacheEvents(dtos);
      return right(dtos.map((dto) => dto.toDomain()).toList());
    } on AppException catch (e) {
      // (4) Network failed — serve stale cache if available.
      if (cachedAt != null) {
        final cached = await _local.getCachedEvents();
        if (cached.isNotEmpty) {
          return right(cached.map((dto) => dto.toDomain()).toList());
        }
      }
      return left(e);
    }
  }

  @override
  Future<Either<AppException, Event>> getEventById(String id) async {
    final result = await getEvents();
    return result.fold(
      left,
      (list) {
        final match = list.where((e) => e.id == id);
        if (match.isEmpty) return left(const CacheException('Event not found'));
        return right(match.first);
      },
    );
  }
}
