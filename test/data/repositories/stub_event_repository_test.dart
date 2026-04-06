import 'package:flutter_test/flutter_test.dart';
import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/data/repositories/stub_event_repository.dart';
import 'package:smart_univ/domain/entities/event.dart';

void main() {
  late StubEventRepository repo;

  setUp(() => repo = StubEventRepository());

  group('StubEventRepository', () {
    group('getEvents()', () {
      test('returns Right with a non-empty list', () async {
        final result = await repo.getEvents();
        expect(result.isRight, isTrue);
        final list = (result as Right<AppException, List<Event>>).value;
        expect(list, isNotEmpty);
      });

      test('every event starts before it ends', () async {
        final result = await repo.getEvents();
        final list = (result as Right).value as List<Event>;
        for (final e in list) {
          expect(e.startTime.isBefore(e.endTime), isTrue);
        }
      });
    });

    group('getEventById()', () {
      test('returns Right for a valid id', () async {
        final result = await repo.getEventById('1');
        expect(result.isRight, isTrue);
      });

      test('returns the correct event', () async {
        final result = await repo.getEventById('2');
        final e = (result as Right<AppException, Event>).value;
        expect(e.id, '2');
        expect(e.title, 'Student Hackathon');
      });

      test('returns Left(CacheException) for unknown id', () async {
        final result = await repo.getEventById('999');
        expect(result.isLeft, isTrue);
        expect((result as Left).value, isA<CacheException>());
      });
    });
  });
}
