import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/domain/entities/event.dart';
import 'package:smart_univ/domain/repositories/event_repository.dart';
import 'package:smart_univ/domain/usecases/get_events_use_case.dart';
import 'package:smart_univ/features/events/presentation/bloc/events_bloc.dart';

class MockEventRepository extends Mock implements EventRepository {}

final _events = [
  Event(
    id: '1',
    title: 'Event: Test',
    description: 'Description',
    startTime: DateTime.utc(2024, 1, 4, 9),
    endTime: DateTime.utc(2024, 1, 4, 11),
    location: 'Hall 1',
  ),
];

void main() {
  late MockEventRepository mockRepository;
  late GetEventsUseCase useCase;
  late EventsBloc bloc;

  setUp(() {
    mockRepository = MockEventRepository();
    useCase = GetEventsUseCase(mockRepository);
    bloc = EventsBloc(useCase);
  });

  tearDown(() => bloc.close());

  test('initial state is EventsInitial', () {
    expect(bloc.state, isA<EventsInitial>());
  });

  group('EventsRequested', () {
    test('emits Loading then Loaded on success', () async {
      when(() => mockRepository.getEvents())
          .thenAnswer((_) async => right(_events));

      bloc.add(const EventsRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<EventsLoading>(),
          isA<EventsLoaded>(),
        ]),
      );

      final loaded = bloc.state as EventsLoaded;
      expect(loaded.events.length, 1);
      expect(loaded.events.first.title, 'Event: Test');
    });

    test('emits Loading then Failure on error', () async {
      when(() => mockRepository.getEvents()).thenAnswer(
        (_) async => left(const NetworkException('Connection timed out')),
      );

      bloc.add(const EventsRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<EventsLoading>(),
          isA<EventsFailure>(),
        ]),
      );

      final failure = bloc.state as EventsFailure;
      expect(failure.message, 'Connection timed out');
    });
  });
}
