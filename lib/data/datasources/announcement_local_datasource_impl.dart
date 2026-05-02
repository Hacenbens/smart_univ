import 'package:drift/drift.dart';
import 'package:smart_univ/data/datasources/announcement_local_datasource.dart';
import 'package:smart_univ/data/local/app_database.dart';
import 'package:smart_univ/data/local/daos/announcements_dao.dart';
import 'package:smart_univ/data/models/announcement_dto.dart';

class AnnouncementLocalDataSourceImpl implements AnnouncementLocalDataSource {
  final AnnouncementsDao _dao;

  AnnouncementLocalDataSourceImpl(this._dao);

  @override
  Future<List<AnnouncementDto>> getCachedAnnouncements() async {
    final rows = await _dao.getAll();
    return rows.map(_rowToDto).toList();
  }

  @override
  Future<void> cacheAnnouncements(List<AnnouncementDto> items) {
    final now = DateTime.now();
    final companions = items
        .map((dto) => AnnouncementsTableCompanion.insert(
              id: Value(dto.id),
              title: dto.title,
              body: dto.body,
              publishedAt: DateTime.utc(2024),
              cachedAt: now,
            ))
        .toList();
    return _dao.upsertAll(companions);
  }

  @override
  Stream<List<AnnouncementDto>> watchAnnouncements() =>
      _dao.watchAll().map((rows) => rows.map(_rowToDto).toList());

  AnnouncementDto _rowToDto(AnnouncementRow row) => AnnouncementDto(
        id: row.id,
        title: row.title,
        body: row.body,
        userId: 0,
      );
}
