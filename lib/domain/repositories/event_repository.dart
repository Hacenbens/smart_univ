import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/domain/entities/event.dart';

abstract interface class EventRepository {
  Future<Either<AppException, List<Event>>> getEvents();
  Future<Either<AppException, Event>> getEventById(String id);
  Future<Either<AppException, Unit>> updateEventPhoto(String id, String path);
}
