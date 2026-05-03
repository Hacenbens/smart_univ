import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/core/usecases/use_case.dart';
import 'package:smart_univ/domain/entities/timetable_item.dart';
import 'package:smart_univ/domain/repositories/timetable_repository.dart';

class GetTimetableUseCase implements UseCase<List<TimetableItem>, NoParams> {
  final TimetableRepository _repository;
  GetTimetableUseCase(this._repository);

  @override
  Future<Either<AppException, List<TimetableItem>>> call(NoParams params) =>
      _repository.getTimetable();
}
