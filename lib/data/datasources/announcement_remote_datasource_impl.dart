import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/core/network/dio_client.dart';
import 'package:smart_univ/data/datasources/announcement_remote_datasource.dart';
import 'package:smart_univ/data/models/announcement_dto.dart';

class AnnouncementRemoteDataSourceImpl implements AnnouncementRemoteDataSource {
  final DioClient _dioClient;

  AnnouncementRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<AnnouncementDto>> getAnnouncements() async {
    try {
      final response = await _dioClient.dio.get('/posts');
      return (response.data as List)
          .map((json) => AnnouncementDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    }
  }
}
