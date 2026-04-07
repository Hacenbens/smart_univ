import 'package:flutter_test/flutter_test.dart';
import 'package:smart_univ/data/repositories/stub_announcement_repository.dart';
import 'package:smart_univ/features/announcements/presentation/bloc/announcements_bloc.dart';

void main() {
  late AnnouncementsBloc bloc;

  setUp(() {
    bloc = AnnouncementsBloc(StubAnnouncementRepository());
  });

  tearDown(() => bloc.close());

  group('AnnouncementsBloc', () {
    test('initial state is AnnouncementsInitial', () {
      expect(bloc.state, isA<AnnouncementsInitial>());
    });

    test('adding AnnouncementsRequested does not throw', () {
      expect(
        () => bloc.add(const AnnouncementsRequested()),
        returnsNormally,
      );
    });

    test('state remains AnnouncementsInitial after AnnouncementsRequested (stub)',
        () async {
      bloc.add(const AnnouncementsRequested());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state, isA<AnnouncementsInitial>());
    });
  });
}
