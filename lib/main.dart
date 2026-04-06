import 'package:flutter/material.dart';
import 'package:smart_univ/core/router/app_router.dart';
import 'package:smart_univ/core/router/auth_state.dart';

void main() {
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
    return MaterialApp.router(
      title: 'SmartCampus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routerConfig: _appRouter.router,
    );
  }
}
