import 'package:json_annotation/json_annotation.dart';
import 'package:smart_univ/domain/entities/announcement.dart';

part 'announcement_dto.g.dart';

@JsonSerializable()
class AnnouncementDto {
  final int id;
  final String title;
  final String body;
  final int userId;

  const AnnouncementDto({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
  });

  factory AnnouncementDto.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AnnouncementDtoToJson(this);

  Announcement toDomain() => Announcement(
        id: id.toString(),
        title: title,
        body: body,
        publishedAt: DateTime.utc(2024),
        authorName: 'User $userId',
        category: _categoryFromId(id),
        isPinned: id % 5 == 0,
      );

  static AnnouncementCategory _categoryFromId(int id) => switch (id % 4) {
        0 => AnnouncementCategory.academic,
        1 => AnnouncementCategory.campusLife,
        2 => AnnouncementCategory.services,
        _ => AnnouncementCategory.general,
      };
}
