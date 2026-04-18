import 'package:json_annotation/json_annotation.dart';
import 'package:smart_univ/domain/entities/timetable_item.dart';

part 'timetable_item_dto.g.dart';

// JSONPlaceholder /todos is used as the source:
//   id → deterministic derivation of dayOfWeek, startHour, room
//   title → subject
//   userId → instructor label

@JsonSerializable()
class TimetableItemDto {
  final int id;
  final String title;
  final int userId;
  final bool completed;

  const TimetableItemDto({
    required this.id,
    required this.title,
    required this.userId,
    required this.completed,
  });

  factory TimetableItemDto.fromJson(Map<String, dynamic> json) =>
      _$TimetableItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TimetableItemDtoToJson(this);

  TimetableItem toDomain() {
    final dayOfWeek = (id % 5) + 1; // 1=Mon … 5=Fri
    final startHour = 8 + (id % 6) * 2; // 8,10,12,14,16,18
    final room = 'Room ${(id % 10) + 1}';
    final baseDate = DateTime.utc(2024, 1, 7 + dayOfWeek - 1);

    return TimetableItem(
      id: id.toString(),
      subject: title,
      room: room,
      instructor: 'Prof. User $userId',
      dayOfWeek: dayOfWeek,
      startTime: baseDate.copyWith(hour: startHour),
      endTime: baseDate.copyWith(hour: startHour + 1, minute: 30),
    );
  }
}
