import 'package:equatable/equatable.dart';

class Event extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String? photoPath;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.photoPath,
  });

  Event copyWith({String? photoPath}) => Event(
        id: id,
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        location: location,
        photoPath: photoPath ?? this.photoPath,
      );

  @override
  List<Object?> get props => [id, title, description, startTime, endTime, location, photoPath];
}
