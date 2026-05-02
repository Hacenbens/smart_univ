import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

enum PermissionResult {
  /// The user granted the permission.
  granted,

  /// The user denied the permission but can be asked again.
  denied,

  /// The user denied the permission and selected "never ask again" (Android)
  /// or the system has blocked the permission (iOS).
  permanentlyDenied,

  /// The permission is restricted by the OS and cannot be granted by the user
  /// (e.g. parental controls on iOS).
  restricted,
}

class PermissionService {
  /// Requests [permission] at runtime and maps the OS response to a
  /// [PermissionResult].
  Future<PermissionResult> requestPermission(Permission permission) async {
    final status = await permission.request();
    return mapStatus(status);
  }

  /// Checks the current status of [permission] without prompting the user.
  Future<PermissionResult> checkPermission(Permission permission) async {
    final status = await permission.status;
    return mapStatus(status);
  }

  /// Maps a raw [PermissionStatus] from permission_handler to the app's own
  /// [PermissionResult]. Exposed for testing.
  @visibleForTesting
  PermissionResult mapStatus(PermissionStatus status) => switch (status) {
        PermissionStatus.granted => PermissionResult.granted,
        // iOS limited (e.g. partial photo library access) is treated as granted
        // so callers receive a usable result without extra handling.
        PermissionStatus.limited => PermissionResult.granted,
        PermissionStatus.denied => PermissionResult.denied,
        PermissionStatus.permanentlyDenied => PermissionResult.permanentlyDenied,
        PermissionStatus.restricted => PermissionResult.restricted,
        _ => PermissionResult.denied,
      };
}
