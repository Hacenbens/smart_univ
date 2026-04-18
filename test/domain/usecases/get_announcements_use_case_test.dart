import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/core/usecases/use_case.dart';
import 'package:smart_univ/domain/entities/announcement.dart';
import 'package:smart_univ/domain/repositories/announcement_repository.dart';
import 'package:smart_univ/domain/usecases/get_announcements_use_case.dart';

class MockAnnouncementRepository extends Mock
    implements AnnouncementRepository {}

final _announcements = [
  Announcement(
    id: '1',
    title: 'Title One',
    body: 'Body one',
    publishedAt: DateTime.utc(2024),
    authorName: 'User 3',
  ),
  Announcement(
    id: '2',
    title: 'Title Two',
    body: 'Body two',
    publishedAt: DateTime.utc(2024),
    authorName: 'User 7',
  ),
];

void main() {
  late MockAnnouncementRepository mockRepository;
  late GetAnnouncementsUseCase useCase;

  setUp(() {
    mockRepository = MockAnnouncementRepository();
    useCase = GetAnnouncementsUseCase(mockRepository);
  });

  test('passes through Right from repository unchanged', () async {
    when(() => mockRepository.getAnnouncements())
        .thenAnswer((_) async => right(_announcements));

    final result = await useCase(const NoParams());

    expect(result.isRight, isTrue);
    result.fold(
      (_) => fail('expected Right'),
      (announcements) {
        expect(announcements.length, 2);
        expect(announcements[0].id, '1');
        expect(announcements[1].id, '2');
      },
    );
    verify(() => mockRepository.getAnnouncements()).called(1);
  });

  test('passes through Left from repository unchanged', () async {
    when(() => mockRepository.getAnnouncements())
        .thenAnswer((_) async => left(const NetworkException('No internet')));

    final result = await useCase(const NoParams());

    expect(result.isLeft, isTrue);
    result.fold(
      (exception) {
        expect(exception, isA<NetworkException>());
        expect(exception.message, 'No internet');
      },
      (_) => fail('expected Left'),
    );
  });
}
