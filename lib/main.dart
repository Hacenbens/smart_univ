import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_univ/core/di/injection_container.dart';
import 'package:smart_univ/core/router/app_router.dart';
import 'package:smart_univ/core/router/auth_state.dart';
import 'package:smart_univ/features/announcements/presentation/bloc/announcements_bloc.dart';
import 'package:smart_univ/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_univ/features/events/presentation/bloc/events_bloc.dart';
import 'package:smart_univ/features/settings/presentation/bloc/settings_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
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
        BlocProvider(create: (_) => sl<AnnouncementsBloc>()),
        BlocProvider(create: (_) => sl<EventsBloc>()),
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<SettingsBloc>()),
      ],
      child: MaterialApp.router(
        title: 'SmartCampus',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        routerConfig: _appRouter.router,
      ),
    );
  }
}
