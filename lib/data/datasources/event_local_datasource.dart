import 'package:smart_univ/data/models/event_dto.dart';

abstract interface class EventLocalDataSource {
  Future<List<EventDto>> getCachedEvents();
  Future<void> cacheEvents(List<EventDto> items);
  Stream<List<EventDto>> watchEvents();
  Future<DateTime?> getLastCachedAt();
  Future<void> updateEventPhotoPath(int id, String path);
}
