import 'package:dio/dio.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/core/network/dio_client.dart';
import 'package:smart_univ/data/datasources/event_remote_datasource.dart';
import 'package:smart_univ/data/models/event_dto.dart';

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final DioClient _dioClient;

  EventRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<EventDto>> getEvents() async {
    try {
      final response = await _dioClient.dio.get(
        '/posts',
        queryParameters: {'_limit': 10},
      );
      return (response.data as List).map((json) {
        final map = Map<String, dynamic>.from(json as Map);
        map['title'] = 'Event: ${map['title']}';
        return EventDto.fromJson(map);
      }).toList();
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error as AppException;
      rethrow;
    } on AppException {
      rethrow;
    }
  }
}
