import 'package:drift/drift.dart';

import '../app_database.dart';

part 'timetable_dao.g.dart';

@DriftAccessor(tables: [TimetableTable])
class TimetableDao extends DatabaseAccessor<AppDatabase>
    with _$TimetableDaoMixin {
  TimetableDao(super.db);

  Stream<List<TimetableRow>> watchAll() => select(timetableTable).watch();

  Future<List<TimetableRow>> getAll() => select(timetableTable).get();

  Future<void> upsertAll(List<TimetableTableCompanion> items) =>
      batch((b) => b.insertAll(
            timetableTable,
            items,
            mode: InsertMode.insertOrReplace,
          ));

  Future<TimetableRow?> getById(int id) =>
      (select(timetableTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> deleteOlderThan(DateTime cutoff) =>
      (delete(timetableTable)
            ..where((t) => t.cachedAt.isSmallerThanValue(cutoff)))
          .go();
}
