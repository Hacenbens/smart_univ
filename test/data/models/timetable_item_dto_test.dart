import 'package:flutter_test/flutter_test.dart';
import 'package:smart_univ/data/models/timetable_item_dto.dart';

void main() {
  const json = {
    'id': 7,
    'title': 'Mathematics',
    'userId': 3,
    'completed': false,
  };

  test('TimetableItemDto.fromJson parses all fields correctly', () {
    final dto = TimetableItemDto.fromJson(json);

    expect(dto.id, 7);
    expect(dto.title, 'Mathematics');
    expect(dto.userId, 3);
    expect(dto.completed, false);
  });

  test('TimetableItemDto.toDomain derives fields deterministically from id', () {
    final dto = TimetableItemDto.fromJson(json);
    final entity = dto.toDomain();

    const id = 7;
    final dayOfWeek = (id % 5) + 1;       // 3
    final startHour = 8 + (id % 6) * 2;   // 8 + 2 = 10 (wait: 7%6=1, 1*2=2, 8+2=10)
    final room = 'Room ${(id % 10) + 1}';  // Room 8
    final baseDate = DateTime.utc(2024, 1, 7 + dayOfWeek - 1);

    expect(entity.id, '7');
    expect(entity.subject, 'Mathematics');
    expect(entity.instructor, 'Prof. User 3');
    expect(entity.dayOfWeek, dayOfWeek);
    expect(entity.room, room);
    expect(entity.startTime, baseDate.copyWith(hour: startHour));
    expect(entity.endTime, baseDate.copyWith(hour: startHour + 1, minute: 30));
  });
}
