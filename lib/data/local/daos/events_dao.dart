import 'package:drift/drift.dart';

import '../app_database.dart';

part 'events_dao.g.dart';

@DriftAccessor(tables: [EventsTable])
class EventsDao extends DatabaseAccessor<AppDatabase> with _$EventsDaoMixin {
  EventsDao(super.db);

  Stream<List<EventRow>> watchAll() => select(eventsTable).watch();

  Future<List<EventRow>> getAll() => select(eventsTable).get();

  Future<void> upsertAll(List<EventRowCompanion> items) =>
      batch((b) => b.insertAll(
            eventsTable,
            items,
            mode: InsertMode.insertOrReplace,
          ));

  Future<int> deleteOlderThan(DateTime cutoff) =>
      (delete(eventsTable)
            ..where((t) => t.cachedAt.isSmallerThanValue(cutoff)))
          .go();
}
