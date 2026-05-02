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
  });
}
