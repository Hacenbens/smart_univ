import 'package:drift/drift.dart';
import 'package:smart_univ/data/datasources/event_local_datasource.dart';
import 'package:smart_univ/data/local/app_database.dart';
import 'package:smart_univ/data/local/daos/events_dao.dart';
import 'package:smart_univ/data/models/event_dto.dart';

class EventLocalDataSourceImpl implements EventLocalDataSource {
  final EventsDao _dao;

  EventLocalDataSourceImpl(this._dao);

  @override
  Future<List<EventDto>> getCachedEvents() async {
    final rows = await _dao.getAll();
    return rows.map(_rowToDto).toList();
  }

  @override
  Future<void> cacheEvents(List<EventDto> items) {
    final now = DateTime.now();
    final companions = items
        .map((dto) => EventsTableCompanion.insert(
              id: Value(dto.id),
              title: dto.title,
              startTime: DateTime.utc(2024, 1, 1)
                  .add(Duration(days: dto.id))
                  .copyWith(hour: 9),
              location: 'Hall ${(dto.id % 5) + 1}',
              cachedAt: now,
            ))
        .toList();
    return _dao.upsertAll(companions);
  }

  @override
  Stream<List<EventDto>> watchEvents() =>
      _dao.watchAll().map((rows) => rows.map(_rowToDto).toList());

  @override
  Future<DateTime?> getLastCachedAt() async {
    final rows = await _dao.getAll();
    if (rows.isEmpty) return null;
    return rows.map((r) => r.cachedAt).reduce((a, b) => a.isBefore(b) ? a : b);
  }

  @override
  Future<void> updateEventPhotoPath(int id, String path) =>
      _dao.updatePhotoPath(id, path);

  EventDto _rowToDto(EventRow row) => EventDto(
        id: row.id,
        title: row.title,
        body: '',
        userId: 0,
        photoPath: row.photoPath,
      );
}
