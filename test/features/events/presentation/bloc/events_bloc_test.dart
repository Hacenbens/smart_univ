import 'package:flutter_test/flutter_test.dart';
import 'package:smart_univ/data/repositories/stub_event_repository.dart';
import 'package:smart_univ/features/events/presentation/bloc/events_bloc.dart';

void main() {
  late EventsBloc bloc;

  setUp(() {
    bloc = EventsBloc(StubEventRepository());
  });

  tearDown(() => bloc.close());

  group('EventsBloc', () {
    test('initial state is EventsInitial', () {
      expect(bloc.state, isA<EventsInitial>());
    });

    test('adding EventsRequested does not throw', () {
      expect(
        () => bloc.add(const EventsRequested()),
        returnsNormally,
      );
    });

    test('state remains EventsInitial after EventsRequested (stub)', () async {
      bloc.add(const EventsRequested());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state, isA<EventsInitial>());
    });
  });
}
