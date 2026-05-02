import 'package:drift/drift.dart';

import '../app_database.dart';

part 'announcements_dao.g.dart';

@DriftAccessor(tables: [AnnouncementsTable])
class AnnouncementsDao extends DatabaseAccessor<AppDatabase>
    with _$AnnouncementsDaoMixin {
  AnnouncementsDao(super.db);

  Stream<List<AnnouncementRow>> watchAll() =>
      select(announcementsTable).watch();

  Future<List<AnnouncementRow>> getAll() => select(announcementsTable).get();

  Future<void> upsertAll(List<AnnouncementRowCompanion> items) =>
      batch((b) => b.insertAll(
            announcementsTable,
            items,
            mode: InsertMode.insertOrReplace,
          ));

  Future<int> deleteOlderThan(DateTime cutoff) =>
      (delete(announcementsTable)
            ..where((t) => t.cachedAt.isSmallerThanValue(cutoff)))
          .go();
}
