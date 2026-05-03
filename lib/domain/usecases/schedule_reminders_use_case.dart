import 'dart:convert';

import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/core/services/notification_service.dart';
import 'package:smart_univ/core/usecases/use_case.dart';
import 'package:smart_univ/domain/entities/timetable_item.dart';
import 'package:smart_univ/domain/repositories/timetable_repository.dart';
import 'package:timezone/timezone.dart' as tz;

class ScheduleRemindersUseCase implements UseCase<int, NoParams> {
  final TimetableRepository _repo;
  final NotificationService _notif;

  ScheduleRemindersUseCase(this._repo, this._notif);

  @override
  Future<Either<AppException, int>> call(NoParams params) async {
    final result = await _repo.getTimetable();
    switch (result) {
      case Left(:final value):
        return Left(value);
      case Right(:final value):
        int scheduled = 0;
        for (final item in value) {
          final candidate = _nextOccurrence(item);
          final reminderTime = candidate.subtract(const Duration(minutes: 10));
          if (reminderTime.isAfter(DateTime.now())) {
            await _notif.scheduleAt(
              id: int.parse(item.id),
              time: tz.TZDateTime.from(reminderTime, tz.local),
              title: 'Class in 10 minutes',
              body: '${item.subject} — ${item.room}',
              payload: jsonEncode({
                'type': 'timetable',
                'id': item.id,
                'courseCode': item.subject,
              }),
              channelId: 'class_reminders',
            );
            scheduled++;
          }
        }
        return Right(scheduled);
    }
  }

  DateTime _nextOccurrence(TimetableItem item) {
    final now = DateTime.now();
    final daysUntil = (item.dayOfWeek - now.weekday) % 7;
    var candidate = DateTime(
      now.year,
      now.month,
      now.day + daysUntil,
      item.startTime.hour,
      item.startTime.minute,
    );
    if (!candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 7));
    }
    return candidate;
  }
}
