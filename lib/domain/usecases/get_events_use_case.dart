import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/core/usecases/use_case.dart';
import 'package:smart_univ/domain/entities/event.dart';
import 'package:smart_univ/domain/repositories/event_repository.dart';

class GetEventsUseCase implements UseCase<List<Event>, NoParams> {
  final EventRepository _repository;

  GetEventsUseCase(this._repository);

  @override
  Future<Either<AppException, List<Event>>> call(NoParams params) =>
      _repository.getEvents();
}
