import 'package:equatable/equatable.dart';

class Announcement extends Equatable {
  final String id;
  final String title;
  final String body;
  final DateTime publishedAt;
  final String authorName;

  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.publishedAt,
    required this.authorName,
  });

  @override
  List<Object?> get props => [id, title, body, publishedAt, authorName];
}
