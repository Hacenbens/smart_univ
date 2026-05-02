import 'package:flutter_test/flutter_test.dart';
import 'package:smart_univ/data/models/announcement_dto.dart';

void main() {
  const json = {
    'id': 1,
    'title': 'Test Title',
    'body': 'Test Body',
    'userId': 5,
  };

  test('AnnouncementDto.fromJson parses all fields correctly', () {
    final dto = AnnouncementDto.fromJson(json);

    expect(dto.id, 1);
    expect(dto.title, 'Test Title');
    expect(dto.body, 'Test Body');
    expect(dto.userId, 5);
  });

  test('AnnouncementDto.toDomain maps to Announcement entity correctly', () {
    final dto = AnnouncementDto.fromJson(json);
    final entity = dto.toDomain();

    expect(entity.id, '1');
    expect(entity.title, 'Test Title');
    expect(entity.body, 'Test Body');
    expect(entity.authorName, 'User 5');
    expect(entity.publishedAt, DateTime.utc(2024));
  });
}
