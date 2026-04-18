import 'package:flutter_test/flutter_test.dart';
import 'package:smart_univ/data/models/event_dto.dart';

void main() {
  const json = {
    'id': 3,
    'title': 'Campus Fair',
    'body': 'Annual campus fair with activities.',
    'userId': 2,
  };

  test('EventDto.fromJson parses all fields correctly', () {
    final dto = EventDto.fromJson(json);

    expect(dto.id, 3);
    expect(dto.title, 'Campus Fair');
    expect(dto.body, 'Annual campus fair with activities.');
    expect(dto.userId, 2);
  });

  test('EventDto.toDomain maps to Event entity correctly', () {
    final dto = EventDto.fromJson(json);
    final entity = dto.toDomain();

    final base = DateTime.utc(2024, 1, 1).add(const Duration(days: 3));

    expect(entity.id, '3');
    expect(entity.title, 'Campus Fair');
    expect(entity.description, 'Annual campus fair with activities.');
    expect(entity.location, 'Hall ${(3 % 5) + 1}');
    expect(entity.startTime, base.copyWith(hour: 9));
    expect(entity.endTime, base.copyWith(hour: 11));
  });
}
