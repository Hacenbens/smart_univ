import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppGoRouterObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (kDebugMode) {
      debugPrint('[Router] PUSH  ${_name(previousRoute)} → ${_name(route)}');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (kDebugMode) {
      debugPrint('[Router] POP   ${_name(route)} → ${_name(previousRoute)}');
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (kDebugMode) {
      debugPrint('[Router] REPLACE ${_name(oldRoute)} → ${_name(newRoute)}');
    }
  }

  String _name(Route<dynamic>? route) => route?.settings.name ?? '(null)';
}
