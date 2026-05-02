import 'package:flutter/foundation.dart';
import 'package:smart_univ/data/local/daos/announcements_dao.dart';
import 'package:smart_univ/data/local/daos/events_dao.dart';

/// Runs once at startup, before [runApp], to evict stale SQLite rows.
///
/// Any cache row older than [_maxCacheAge] is pruned so the on-device database
/// does not grow unboundedly across weeks of use.
class AppInitializationUseCase {
  static const _maxCacheAge = Duration(days: 7);

  final AnnouncementsDao _announcementsDao;
  final EventsDao _eventsDao;

  AppInitializationUseCase(this._announcementsDao, this._eventsDao);

  Future<void> call() async {
    final cutoff = DateTime.now().subtract(_maxCacheAge);
    final counts = await Future.wait([
      _announcementsDao.deleteOlderThan(cutoff),
      _eventsDao.deleteOlderThan(cutoff),
    ]);
    debugPrint(
      '[AppInit] Cache eviction: pruned ${counts[0]} announcement(s) '
      'and ${counts[1]} event(s) older than 7 days.',
    );
  }
}
