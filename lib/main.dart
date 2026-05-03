import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';
import 'package:smart_univ/core/cubit/connectivity_cubit.dart';
import 'package:smart_univ/core/di/injection_container.dart';
import 'package:smart_univ/core/usecases/app_initialization_use_case.dart';
import 'package:smart_univ/core/router/app_router.dart';
import 'package:smart_univ/core/router/auth_state.dart';
import 'package:smart_univ/core/services/notification_service.dart';
import 'package:smart_univ/core/theme/app_theme.dart';
import 'package:smart_univ/data/local/app_database.dart';
import 'package:smart_univ/data/local/daos/timetable_dao.dart';
import 'package:smart_univ/domain/usecases/announcement_sync_use_case.dart';
import 'package:smart_univ/features/announcements/presentation/bloc/announcements_bloc.dart';
import 'package:smart_univ/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_univ/features/events/presentation/bloc/events_bloc.dart';
import 'package:smart_univ/features/home/presentation/bloc/home_bloc.dart';
import 'package:smart_univ/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:smart_univ/features/timetable/presentation/bloc/timetable_bloc.dart';

// Must be a top-level function so WorkManager's background isolate can resolve
// the symbol. The @pragma prevents AOT tree-shaking in release builds.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    switch (taskName) {
      case 'announcementSync':
        WidgetsFlutterBinding.ensureInitialized();
        await initDependencies();
        final useCase = sl<AnnouncementSyncUseCase>();
        await useCase.call();
        await sl<AppDatabase>().close();
    }
    return true;
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(await FlutterTimezone.getLocalTimezone()));
  await initDependencies();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await Workmanager().registerPeriodicTask(
    'announcement-sync',
    'announcementSync',
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
  );
  await sl<NotificationService>().init(navigatorKey: AppRouter.navigatorKey);
  await sl<AppInitializationUseCase>().call();
  await _seedTimetableData();

  final launchDetails =
      await sl<NotificationService>().getAppLaunchDetails();
  String? initialLocation;
  if (launchDetails?.didNotificationLaunchApp == true) {
    final payload = launchDetails!.notificationResponse?.payload;
    if (payload != null) {
      try {
        final map = jsonDecode(payload) as Map<String, dynamic>;
        if (map['type'] == 'timetable') {
          initialLocation = '/timetable/${map['id']}';
        }
      } catch (_) {}
    }
  }

  runApp(SmartCampusApp(initialLocation: initialLocation));
}

Future<void> _seedTimetableData() async {
  final now = DateTime.now();
  await sl<TimetableDao>().upsertAll([
    TimetableTableCompanion(id: Value(1), courseCode: Value('Mobile Development'),           dayOfWeek: Value(1), startHour: Value(9),  room: Value('Room 3A'), cachedAt: Value(now)),
    TimetableTableCompanion(id: Value(2), courseCode: Value('Algorithms & Data Structures'), dayOfWeek: Value(2), startHour: Value(11), room: Value('Room 2B'), cachedAt: Value(now)),
    TimetableTableCompanion(id: Value(3), courseCode: Value('Computer Networks'),            dayOfWeek: Value(3), startHour: Value(14), room: Value('Lab 1'),   cachedAt: Value(now)),
    TimetableTableCompanion(id: Value(4), courseCode: Value('Software Engineering'),         dayOfWeek: Value(4), startHour: Value(8),  room: Value('Room 4C'), cachedAt: Value(now)),
    TimetableTableCompanion(id: Value(5), courseCode: Value('Database Systems'),             dayOfWeek: Value(5), startHour: Value(10), room: Value('Lab 2'),   cachedAt: Value(now)),
  ]);
}

class SmartCampusApp extends StatefulWidget {
  final String? initialLocation;
  const SmartCampusApp({super.key, this.initialLocation});

  @override
  State<SmartCampusApp> createState() => _SmartCampusAppState();
}

class _SmartCampusAppState extends State<SmartCampusApp> {
  final AuthState _authState = AuthState();
  late final AppRouter _appRouter =
      AppRouter(_authState, initialLocation: widget.initialLocation);

  @override
  void dispose() {
    _authState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ConnectivityCubit>()),
        BlocProvider(create: (_) => sl<HomeBloc>()),
        BlocProvider(create: (_) => sl<AnnouncementsBloc>()),
        BlocProvider(create: (_) => sl<EventsBloc>()),
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<SettingsBloc>()),
        BlocProvider(create: (_) => sl<TimetableBloc>()),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settings) {
          return MaterialApp.router(
            title: 'SmartCampus',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            routerConfig: _appRouter.router,
          );
        },
      ),
    );
  }
}
