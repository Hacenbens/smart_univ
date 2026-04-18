import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/data/datasources/event_remote_datasource.dart';
import 'package:smart_univ/domain/entities/event.dart';
import 'package:smart_univ/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource _dataSource;

  EventRepositoryImpl(this._dataSource);

  @override
  Future<Either<AppException, List<Event>>> getEvents() async {
    try {
      final dtos = await _dataSource.getEvents();
      return right(dtos.map((dto) => dto.toDomain()).toList());
    } on AppException catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<AppException, Event>> getEventById(String id) async {
    try {
      final dtos = await _dataSource.getEvents();
      final match = dtos.where((dto) => dto.id.toString() == id);
      if (match.isEmpty) return left(const CacheException('Event not found'));
      return right(match.first.toDomain());
    } on AppException catch (e) {
      return left(e);
    }
  }
}
