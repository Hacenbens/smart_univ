import 'package:fpdart/fpdart.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/domain/entities/event.dart';
import 'package:smart_univ/domain/repositories/event_repository.dart';

class StubEventRepository implements EventRepository {
  static final _events = [
    Event(
      id: '1',
      title: 'Tech Talk: AI in Education',
      description: 'A guest lecture exploring AI applications in modern universities.',
      startTime: DateTime(2026, 4, 10, 14, 0),
      endTime: DateTime(2026, 4, 10, 16, 0),
      location: 'Auditorium A',
    ),
    Event(
      id: '2',
      title: 'Student Hackathon',
      description: '24-hour hackathon open to all students. Form teams of up to 4.',
      startTime: DateTime(2026, 4, 18, 9, 0),
      endTime: DateTime(2026, 4, 19, 9, 0),
      location: 'Innovation Lab',
    ),
  ];

  @override
  Future<Either<AppException, List<Event>>> getEvents() async => right(_events);

  @override
  Future<Either<AppException, Event>> getEventById(String id) async {
    final match = _events.where((e) => e.id == id).toList();
    if (match.isEmpty) return left(const CacheException('Event not found'));
    return right(match.first);
  }
}
