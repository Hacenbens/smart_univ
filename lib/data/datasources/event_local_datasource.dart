import 'package:smart_univ/data/models/event_dto.dart';

abstract interface class EventLocalDataSource {
  Future<List<EventDto>> getCachedEvents();
  Future<void> cacheEvents(List<EventDto> items);
  Stream<List<EventDto>> watchEvents();
  /// Returns the oldest cachedAt across all rows, or null if the cache is empty.
  Future<DateTime?> getLastCachedAt();
}
