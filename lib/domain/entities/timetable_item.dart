import 'package:equatable/equatable.dart';

class TimetableItem extends Equatable {
  final String id;
  final String subject;
  final String room;
  final String instructor;
  final int dayOfWeek; // 1 = Monday … 7 = Sunday
  final DateTime startTime;
  final DateTime endTime;

  const TimetableItem({
    required this.id,
    required this.subject,
    required this.room,
    required this.instructor,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [id, subject, room, instructor, dayOfWeek, startTime, endTime];
}
