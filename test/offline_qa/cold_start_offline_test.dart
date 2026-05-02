// QA Scenario 1 — Cold Start Offline
//
// Simulates: airplane mode ON → app terminated → app reopened.
//
// Expected behaviour under test:
//   - Cached announcements render immediately (no network call needed)
//   - Offline banner ("You are offline — showing cached content") is visible
//   - No AppErrorWidget appears in the tree
//   - Widget tree builds and settles without throwing

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_univ/core/cubit/connectivity_cubit.dart';
import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/services/connectivity_service.dart';
import 'package:smart_univ/core/widgets/app_error_widget.dart';
import 'package:smart_univ/domain/entities/announcement.dart';
import 'package:smart_univ/domain/repositories/announcement_repository.dart';
import 'package:smart_univ/domain/usecases/get_announcements_use_case.dart';
import 'package:smart_univ/features/announcements/presentation/bloc/announcements_bloc.dart';
import 'package:smart_univ/features/announcements/presentation/pages/announcements_page.dart';
import 'package:smart_univ/presentation/shell/scaffold_with_nav_bar.dart';

class _MockAnnouncementRepository extends Mock
    implements AnnouncementRepository {}

class _MockConnectivityService extends Mock implements ConnectivityService {}

// Two announcements that were cached on a previous online session.
final _cachedAnnouncements = [
  Announcement(
    id: '1',
    title: 'Week 3 Recap',
    body: 'Slides are now available on the portal.',
    publishedAt: DateTime.utc(2024, 1, 15),
    authorName: 'Prof. Martin',
  ),
  Announcement(
    id: '2',
    title: 'Library Extended Hours',
    body: 'Open until midnight during exam period.',
    publishedAt: DateTime.utc(2024, 1, 14),
    authorName: 'Library',
  ),
];

void main() {
  // Required because AnnouncementsBloc registers a WidgetsBindingObserver.
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockAnnouncementRepository mockRepo;
  late _MockConnectivityService mockConnectivity;
  late AnnouncementsBloc announcementsBloc;
  late ConnectivityCubit connectivityCubit;

  setUp(() {
    mockRepo = _MockAnnouncementRepository();
    mockConnectivity = _MockConnectivityService();

    // Device is offline — stream immediately emits false.
    when(() => mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => Stream.value(false));

    // Repository serves the local cache (no network required).
    when(() => mockRepo.getAnnouncements())
        .thenAnswer((_) async => right(_cachedAnnouncements));

    announcementsBloc =
        AnnouncementsBloc(GetAnnouncementsUseCase(mockRepo));
    connectivityCubit = ConnectivityCubit(mockConnectivity);
  });

  tearDown(() {
    announcementsBloc.close();
    connectivityCubit.close();
  });

  // Minimal router: only the announcements shell route is needed for this scenario.
  GoRouter _buildRouter() => GoRouter(
        initialLocation: '/announcements',
        routes: [
          ShellRoute(
            builder: (context, state, child) =>
                ScaffoldWithNavBar(child: child),
            routes: [
              GoRoute(
                path: '/announcements',
                builder: (context, state) => const AnnouncementsPage(),
              ),
            ],
          ),
        ],
      );

  Widget buildApp() => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: connectivityCubit),
          BlocProvider.value(value: announcementsBloc),
        ],
        child: MaterialApp.router(routerConfig: _buildRouter()),
      );

  group('QA Scenario 1 — Cold Start Offline', () {
    testWidgets('cached announcements are displayed without a network call',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Week 3 Recap'), findsOneWidget);
      expect(find.text('Library Extended Hours'), findsOneWidget);

      // Repository was called exactly once — the BLoC fetched from cache.
      verify(() => mockRepo.getAnnouncements()).called(1);
    });

    testWidgets('offline banner is visible', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(
        find.text('You are offline — showing cached content'),
        findsOneWidget,
      );
    });

    testWidgets('no error screen is shown', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorWidget), findsNothing);
    });

    testWidgets('widget tree builds and settles without throwing', (tester) async {
      await expectLater(
        () async {
          await tester.pumpWidget(buildApp());
          await tester.pumpAndSettle();
        },
        returnsNormally,
      );
    });
  });
}
