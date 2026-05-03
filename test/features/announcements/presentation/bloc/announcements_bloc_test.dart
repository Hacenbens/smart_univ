import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/domain/entities/announcement.dart';
import 'package:smart_univ/domain/repositories/announcement_repository.dart';
import 'package:smart_univ/domain/usecases/get_announcements_use_case.dart';
import 'package:smart_univ/features/announcements/presentation/bloc/announcements_bloc.dart';

class MockAnnouncementRepository extends Mock
    implements AnnouncementRepository {}

final _announcements = [
  Announcement(
    id: '1',
    title: 'Test',
    body: 'Body',
    publishedAt: DateTime.utc(2024),
    authorName: 'Author',
  ),
];

void main() {
  // Required so WidgetsBinding.instance is available in the bloc constructor.
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAnnouncementRepository mockRepository;
  late GetAnnouncementsUseCase useCase;
  late AnnouncementsBloc bloc;

  setUp(() {
    mockRepository = MockAnnouncementRepository();
    useCase = GetAnnouncementsUseCase(mockRepository);
    bloc = AnnouncementsBloc(useCase);
  });

  tearDown(() => bloc.close());

  test('initial state is AnnouncementsInitial', () {
    expect(bloc.state, isA<AnnouncementsInitial>());
  });

  group('AnnouncementsRequested', () {
    test('emits Loading then Loaded on success', () async {
      when(() => mockRepository.getAnnouncements())
          .thenAnswer((_) async => right(_announcements));

      bloc.add(const AnnouncementsRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AnnouncementsLoading>(),
          isA<AnnouncementsLoaded>(),
        ]),
      );

      final loaded = bloc.state as AnnouncementsLoaded;
      expect(loaded.announcements.length, 1);
      expect(loaded.announcements.first.title, 'Test');
    });

    test('emits Loading then Failure on error', () async {
      when(() => mockRepository.getAnnouncements()).thenAnswer(
        (_) async => left(const NetworkException('No internet')),
      );

      bloc.add(const AnnouncementsRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AnnouncementsLoading>(),
          isA<AnnouncementsFailure>(),
        ]),
      );

      final failure = bloc.state as AnnouncementsFailure;
      expect(failure.message, 'No internet');
    });

    test('updates lastFetchedAt after a successful fetch', () async {
      when(() => mockRepository.getAnnouncements())
          .thenAnswer((_) async => right(_announcements));

      expect(bloc.lastFetchedAt, isNull);

      bloc.add(const AnnouncementsRequested());
      await expectLater(
        bloc.stream,
        emitsInOrder([isA<AnnouncementsLoading>(), isA<AnnouncementsLoaded>()]),
      );

      expect(bloc.lastFetchedAt, isNotNull);
    });

    test('does not update lastFetchedAt on failure', () async {
      when(() => mockRepository.getAnnouncements())
          .thenAnswer((_) async => left(const NetworkException('err')));

      bloc.add(const AnnouncementsRequested());
      await expectLater(
        bloc.stream,
        emitsInOrder([isA<AnnouncementsLoading>(), isA<AnnouncementsFailure>()]),
      );

      expect(bloc.lastFetchedAt, isNull);
    });
  });

  group('AppLifecycle.resumed auto-refresh', () {
    test('triggers refresh when lastFetchedAt is null (never fetched)', () async {
      when(() => mockRepository.getAnnouncements())
          .thenAnswer((_) async => right(_announcements));

      // lastFetchedAt is null by default — simulates first launch.
      bloc.didChangeAppLifecycleState(AppLifecycleState.resumed);

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AnnouncementsLoading>(),
          isA<AnnouncementsLoaded>(),
        ]),
      );
    });

    test('triggers refresh when last fetch was older than 15 minutes', () async {
      when(() => mockRepository.getAnnouncements())
          .thenAnswer((_) async => right(_announcements));

      // Backdate lastFetchedAt to 20 minutes ago.
      bloc.lastFetchedAt =
          DateTime.now().subtract(const Duration(minutes: 20));

      bloc.didChangeAppLifecycleState(AppLifecycleState.resumed);

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AnnouncementsLoading>(),
          isA<AnnouncementsLoaded>(),
        ]),
      );
    });

    test('does NOT trigger refresh when last fetch was within 15 minutes', () async {
      // Backdate lastFetchedAt to 5 minutes ago — still fresh.
      bloc.lastFetchedAt =
          DateTime.now().subtract(const Duration(minutes: 5));

      bloc.didChangeAppLifecycleState(AppLifecycleState.resumed);

      // Give the event loop a chance to process any spurious events.
      await Future<void>.delayed(Duration.zero);

      // Stream should emit nothing — bloc is still in its initial state.
      expect(bloc.state, isA<AnnouncementsInitial>());
      verifyNever(() => mockRepository.getAnnouncements());
    });

    test('does NOT trigger refresh on pause or detach lifecycle events', () async {
      bloc.didChangeAppLifecycleState(AppLifecycleState.paused);
      bloc.didChangeAppLifecycleState(AppLifecycleState.detached);

      await Future<void>.delayed(Duration.zero);

      expect(bloc.state, isA<AnnouncementsInitial>());
      verifyNever(() => mockRepository.getAnnouncements());
    });
  });
}
