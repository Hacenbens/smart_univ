import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_univ/core/usecases/app_initialization_use_case.dart';
import 'package:smart_univ/data/local/daos/announcements_dao.dart';
import 'package:smart_univ/data/local/daos/events_dao.dart';

class MockAnnouncementsDao extends Mock implements AnnouncementsDao {}

class MockEventsDao extends Mock implements EventsDao {}

void main() {
  late MockAnnouncementsDao mockAnnouncementsDao;
  late MockEventsDao mockEventsDao;
  late AppInitializationUseCase useCase;

  setUp(() {
    mockAnnouncementsDao = MockAnnouncementsDao();
    mockEventsDao = MockEventsDao();
    useCase = AppInitializationUseCase(mockAnnouncementsDao, mockEventsDao);
  });

  group('AppInitializationUseCase', () {
    test('calls deleteOlderThan on both DAOs with a 7-day cutoff', () async {
      when(() => mockAnnouncementsDao.deleteOlderThan(any()))
          .thenAnswer((_) async => 3);
      when(() => mockEventsDao.deleteOlderThan(any()))
          .thenAnswer((_) async => 1);

      final lowerBound =
          DateTime.now().subtract(const Duration(days: 7, seconds: 1));

      await useCase();

      final upperBound =
          DateTime.now().subtract(const Duration(days: 7)).add(const Duration(seconds: 1));

      final announcementsCutoff =
          verify(() => mockAnnouncementsDao.deleteOlderThan(captureAny()))
              .captured
              .single as DateTime;
      final eventsCutoff =
          verify(() => mockEventsDao.deleteOlderThan(captureAny()))
              .captured
              .single as DateTime;

      // Both cutoffs should fall inside the 7-days-ago window (±1 s tolerance).
      expect(announcementsCutoff.isAfter(lowerBound), isTrue);
      expect(announcementsCutoff.isBefore(upperBound), isTrue);
      expect(eventsCutoff.isAfter(lowerBound), isTrue);
      expect(eventsCutoff.isBefore(upperBound), isTrue);
    });

    test('evicts zero rows without throwing when the cache is already clean',
        () async {
      when(() => mockAnnouncementsDao.deleteOlderThan(any()))
          .thenAnswer((_) async => 0);
      when(() => mockEventsDao.deleteOlderThan(any()))
          .thenAnswer((_) async => 0);

      await expectLater(useCase(), completes);
    });

    test('calls both DAOs exactly once per invocation', () async {
      when(() => mockAnnouncementsDao.deleteOlderThan(any()))
          .thenAnswer((_) async => 0);
      when(() => mockEventsDao.deleteOlderThan(any()))
          .thenAnswer((_) async => 0);

      await useCase();

      verify(() => mockAnnouncementsDao.deleteOlderThan(any())).called(1);
      verify(() => mockEventsDao.deleteOlderThan(any())).called(1);
    });
  });
}
