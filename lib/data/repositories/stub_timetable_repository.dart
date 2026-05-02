import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/domain/entities/timetable_item.dart';
import 'package:smart_univ/domain/repositories/timetable_repository.dart';

class StubTimetableRepository implements TimetableRepository {
  static final _items = [
    TimetableItem(
      id: '1',
      subject: 'Mobile Development',
      room: 'Room 3A',
      instructor: 'Prof. Martin',
      dayOfWeek: 1,
      startTime: DateTime.utc(2024, 1, 8, 9),
      endTime: DateTime.utc(2024, 1, 8, 10, 30),
    ),
    TimetableItem(
      id: '2',
      subject: 'Algorithms & Data Structures',
      room: 'Room 2B',
      instructor: 'Prof. Benali',
      dayOfWeek: 2,
      startTime: DateTime.utc(2024, 1, 9, 11),
      endTime: DateTime.utc(2024, 1, 9, 12, 30),
    ),
    TimetableItem(
      id: '3',
      subject: 'Computer Networks',
      room: 'Lab 1',
      instructor: 'Prof. Hassan',
      dayOfWeek: 3,
      startTime: DateTime.utc(2024, 1, 10, 14),
      endTime: DateTime.utc(2024, 1, 10, 15, 30),
    ),
    TimetableItem(
      id: '4',
      subject: 'Software Engineering',
      room: 'Room 4C',
      instructor: 'Prof. Dupont',
      dayOfWeek: 4,
      startTime: DateTime.utc(2024, 1, 11, 8),
      endTime: DateTime.utc(2024, 1, 11, 9, 30),
    ),
    TimetableItem(
      id: '5',
      subject: 'Database Systems',
      room: 'Lab 2',
      instructor: 'Prof. Ahmed',
      dayOfWeek: 5,
      startTime: DateTime.utc(2024, 1, 12, 10),
      endTime: DateTime.utc(2024, 1, 12, 11, 30),
    ),
  ];

  @override
  Future<Either<AppException, List<TimetableItem>>> getTimetable() async =>
      right(_items);
}
