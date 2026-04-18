import 'package:smart_univ/data/models/event_dto.dart';

abstract interface class EventRemoteDataSource {
  Future<List<EventDto>> getEvents();
}
