import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/data/datasources/announcement_remote_datasource.dart';
import 'package:smart_univ/data/models/announcement_dto.dart';
import 'package:smart_univ/data/repositories/announcement_repository_impl.dart';

class MockAnnouncementRemoteDataSource extends Mock
    implements AnnouncementRemoteDataSource {}

const _dtos = [
  AnnouncementDto(id: 1, title: 'Title One', body: 'Body one', userId: 3),
  AnnouncementDto(id: 2, title: 'Title Two', body: 'Body two', userId: 7),
];

void main() {
  late MockAnnouncementRemoteDataSource mockDataSource;
  late AnnouncementRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockAnnouncementRemoteDataSource();
    repository = AnnouncementRepositoryImpl(mockDataSource);
  });

  group('getAnnouncements', () {
    test('returns Right with correctly mapped entities on success', () async {
      when(() => mockDataSource.getAnnouncements())
          .thenAnswer((_) async => _dtos);

      final result = await repository.getAnnouncements();

      expect(result.isRight, isTrue);
      result.fold(
        (_) => fail('expected Right'),
        (announcements) {
          expect(announcements.length, 2);

          expect(announcements[0].id, '1');
          expect(announcements[0].title, 'Title One');
          expect(announcements[0].body, 'Body one');
          expect(announcements[0].authorName, 'User 3');

          expect(announcements[1].id, '2');
          expect(announcements[1].title, 'Title Two');
          expect(announcements[1].body, 'Body two');
          expect(announcements[1].authorName, 'User 7');
        },
      );
    });

    test('returns Left with NetworkException when data source throws', () async {
      when(() => mockDataSource.getAnnouncements())
          .thenThrow(const NetworkException('Connection timed out'));

      final result = await repository.getAnnouncements();

      expect(result.isLeft, isTrue);
      result.fold(
        (exception) {
          expect(exception, isA<NetworkException>());
          expect(exception.message, 'Connection timed out');
        },
        (_) => fail('expected Left'),
      );
    });
  });

  group('getAnnouncementById', () {
    test('returns Right with matching entity when id exists', () async {
      when(() => mockDataSource.getAnnouncements())
          .thenAnswer((_) async => _dtos);

      final result = await repository.getAnnouncementById('2');

      expect(result.isRight, isTrue);
      result.fold(
        (_) => fail('expected Right'),
        (announcement) {
          expect(announcement.id, '2');
          expect(announcement.title, 'Title Two');
        },
      );
    });

    test('returns Left with CacheException when id not found', () async {
      when(() => mockDataSource.getAnnouncements())
          .thenAnswer((_) async => _dtos);

      final result = await repository.getAnnouncementById('999');

      expect(result.isLeft, isTrue);
      result.fold(
        (exception) => expect(exception, isA<CacheException>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
