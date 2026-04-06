import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String studentId;
  final String department;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.studentId,
    required this.department,
  });

  @override
  List<Object?> get props => [id, fullName, email, studentId, department];
}
