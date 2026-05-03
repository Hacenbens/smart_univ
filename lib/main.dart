import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:smart_univ/core/cubit/connectivity_cubit.dart';
import 'package:smart_univ/core/di/injection_container.dart';
import 'package:smart_univ/core/usecases/app_initialization_use_case.dart';
import 'package:smart_univ/core/router/app_router.dart';
import 'package:smart_univ/core/router/auth_state.dart';
import 'package:smart_univ/core/theme/app_theme.dart';
import 'package:smart_univ/features/announcements/presentation/bloc/announcements_bloc.dart';
import 'package:smart_univ/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_univ/features/events/presentation/bloc/events_bloc.dart';
import 'package:smart_univ/core/services/notification_service.dart';
import 'package:smart_univ/features/home/presentation/bloc/home_bloc.dart';
import 'package:smart_univ/features/settings/presentation/bloc/settings_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(await FlutterTimezone.getLocalTimezone()));
  await initDependencies();
  await sl<NotificationService>().init();
  await sl<AppInitializationUseCase>().call();
  runApp(const SmartCampusApp());
}

class SmartCampusApp extends StatefulWidget {
  const SmartCampusApp({super.key});

  @override
  State<SmartCampusApp> createState() => _SmartCampusAppState();
}

class _SmartCampusAppState extends State<SmartCampusApp> {
  final AuthState _authState = AuthState();
  late final AppRouter _appRouter = AppRouter(_authState);

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
