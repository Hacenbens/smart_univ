import 'package:json_annotation/json_annotation.dart';
import 'package:smart_univ/domain/entities/event.dart';

part 'event_dto.g.dart';

@JsonSerializable()
class EventDto {
  final int id;
  final String title;
  final String body;
  final int userId;

  const EventDto({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
  });

  factory EventDto.fromJson(Map<String, dynamic> json) =>
      _$EventDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EventDtoToJson(this);

  Event toDomain() {
    final base = DateTime.utc(2024, 1, 1).add(Duration(days: id));
    return Event(
      id: id.toString(),
      title: title,
      description: body,
      startTime: base.copyWith(hour: 9),
      endTime: base.copyWith(hour: 11),
      location: 'Hall ${(id % 5) + 1}',
    );
  }
}
