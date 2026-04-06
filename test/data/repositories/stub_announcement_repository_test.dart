import 'package:flutter_test/flutter_test.dart';
import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/data/repositories/stub_announcement_repository.dart';
import 'package:smart_univ/domain/entities/announcement.dart';

void main() {
  late StubAnnouncementRepository repo;

  setUp(() => repo = StubAnnouncementRepository());

  group('StubAnnouncementRepository', () {
    group('getAnnouncements()', () {
      test('returns Right with a non-empty list', () async {
        final result = await repo.getAnnouncements();
        expect(result.isRight, isTrue);
        final list = (result as Right<AppException, List<Announcement>>).value;
        expect(list, isNotEmpty);
      });

      test('every item has a non-empty title and id', () async {
        final result = await repo.getAnnouncements();
        final list = (result as Right).value as List<Announcement>;
        for (final a in list) {
          expect(a.id, isNotEmpty);
          expect(a.title, isNotEmpty);
        }
      });
    });

    group('getAnnouncementById()', () {
      test('returns Right for a valid id', () async {
        final result = await repo.getAnnouncementById('1');
        expect(result.isRight, isTrue);
      });

      test('returns the correct announcement', () async {
        final result = await repo.getAnnouncementById('2');
        final a = (result as Right<AppException, Announcement>).value;
        expect(a.id, '2');
        expect(a.authorName, 'Library Services');
      });

      test('returns Left(CacheException) for unknown id', () async {
        final result = await repo.getAnnouncementById('999');
        expect(result.isLeft, isTrue);
        expect((result as Left).value, isA<CacheException>());
      });
    });
  });
}
