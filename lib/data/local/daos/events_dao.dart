import 'package:drift/drift.dart';

import '../app_database.dart';

part 'events_dao.g.dart';

@DriftAccessor(tables: [EventsTable])
class EventsDao extends DatabaseAccessor<AppDatabase> with _$EventsDaoMixin {
  EventsDao(super.db);

  Stream<List<EventRow>> watchAll() => select(eventsTable).watch();

  Future<List<EventRow>> getAll() => select(eventsTable).get();

  // Uses ON CONFLICT DO UPDATE targeting only network-sourced columns so that
  // a user-set photoPath is preserved across cache refreshes.
  Future<void> upsertAll(List<EventsTableCompanion> items) =>
      batch((b) {
        for (final item in items) {
          b.insert(
            eventsTable,
            item,
            onConflict: DoUpdate(
              (_) => EventsTableCompanion(
                title: item.title,
                startTime: item.startTime,
                location: item.location,
                cachedAt: item.cachedAt,
              ),
            ),
          );
        }
      });

  Future<void> updatePhotoPath(int id, String path) =>
      (update(eventsTable)..where((t) => t.id.equals(id)))
          .write(EventsTableCompanion(photoPath: Value(path)));

  Future<int> deleteOlderThan(DateTime cutoff) =>
      (delete(eventsTable)
            ..where((t) => t.cachedAt.isSmallerThanValue(cutoff)))
          .go();
}
