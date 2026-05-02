import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/domain/entities/timetable_item.dart';

abstract interface class TimetableRepository {
  Future<Either<AppException, List<TimetableItem>>> getTimetable();
}
