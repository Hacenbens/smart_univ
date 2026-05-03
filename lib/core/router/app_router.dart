import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_univ/core/router/auth_state.dart';
import 'package:smart_univ/core/router/go_router_observer.dart';
import 'package:smart_univ/features/announcements/presentation/pages/announcements_page.dart';
import 'package:smart_univ/features/auth/presentation/pages/login_page.dart';
import 'package:smart_univ/features/events/presentation/pages/events_page.dart';
import 'package:smart_univ/features/map/presentation/pages/map_screen.dart';
import 'package:smart_univ/features/settings/presentation/pages/settings_page.dart';
import 'package:smart_univ/features/timetable/presentation/pages/timetable_detail_screen.dart';
import 'package:smart_univ/features/timetable/presentation/pages/timetable_page.dart';
import 'package:smart_univ/presentation/pages/home_page.dart';
import 'package:smart_univ/presentation/shell/scaffold_with_nav_bar.dart';

class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();

  final AuthState authState;
  final String? initialLocation;

  AppRouter(this.authState, {this.initialLocation});

  late final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: initialLocation ?? '/home',
    debugLogDiagnostics: true,
    observers: [AppGoRouterObserver()],
    refreshListenable: authState,
    redirect: (BuildContext context, GoRouterState state) {
      final loggedIn = authState.isLoggedIn;
      final onLogin = state.matchedLocation == '/login';

      if (!loggedIn && !onLogin) return '/login';
      if (loggedIn && onLogin) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(authState: authState),
      ),
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithNavBar(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => HomePage(authState: authState),
          ),
          GoRoute(
            path: '/announcements',
            builder: (context, state) => const AnnouncementsPage(),
          ),
          GoRoute(
            path: '/events',
            builder: (context, state) => const EventsPage(),
          ),
          GoRoute(
            path: '/map',
            builder: (context, state) => const MapScreen(),
          ),
          GoRoute(
            path: '/timetable',
            builder: (context, state) => const TimetablePage(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return TimetableDetailScreen(id: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
}
