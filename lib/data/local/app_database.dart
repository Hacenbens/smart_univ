import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/announcements_dao.dart';
import 'daos/events_dao.dart';
import 'daos/timetable_dao.dart';

part 'app_database.g.dart';

@DataClassName('AnnouncementRow')
class AnnouncementsTable extends Table {
  IntColumn get id => integer()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  DateTimeColumn get publishedAt => dateTime()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('EventRow')
class EventsTable extends Table {
  IntColumn get id => integer()();
  TextColumn get title => text()();
  DateTimeColumn get startTime => dateTime()();
  TextColumn get location => text()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TimetableRow')
class TimetableTable extends Table {
  IntColumn get id => integer()();
  TextColumn get courseCode => text()();
  IntColumn get dayOfWeek => integer()();
  IntColumn get startHour => integer()();
  TextColumn get room => text()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [AnnouncementsTable, EventsTable, TimetableTable],
  daos: [AnnouncementsDao, EventsDao, TimetableDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'smart_univ_db');
  }
}
