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

/// Central permission gateway for the app.
///
/// ## Rule: check first, request on explicit user action
///
/// ```
/// // At screen init — never triggers a dialog:
/// final result = await permissionService.checkPermission(Permission.camera);
/// if (result == PermissionResult.granted) { showFeature(); }
/// else { showRationaleUI(); }
///
/// // Only when the user taps a feature button:
/// final result = await permissionService.requestPermission(Permission.camera);
/// ```
///
/// Calling [requestPermission] at startup violates OS guidelines and
/// degrades user trust. Always call [checkPermission] first.
class PermissionService {
  /// Returns the current status of [permission] **without** showing a system
  /// dialog. Safe to call at screen initialisation, in initState, or inside
  /// a BLoC's initial data-fetch.
  Future<PermissionResult> checkPermission(Permission permission) async {
    final status = await permission.status;
    return mapStatus(status);
  }

  /// Shows the system permission dialog for [permission] and returns the
  /// user's decision. Only call this in response to an explicit user gesture
  /// (button tap, menu action, etc.) — never at app or screen startup.
  Future<PermissionResult> requestPermission(Permission permission) async {
    final status = await permission.request();
    return mapStatus(status);
  }

  /// Maps a raw [PermissionStatus] from permission_handler to [PermissionResult].
  ///
  /// [PermissionStatus.limited] (iOS partial photo library access) maps to
  /// [PermissionResult.granted] so callers receive a usable result without
  /// needing to handle a fifth variant.
  @visibleForTesting
  PermissionResult mapStatus(PermissionStatus status) => switch (status) {
        PermissionStatus.granted => PermissionResult.granted,
        PermissionStatus.limited => PermissionResult.granted,
        PermissionStatus.denied => PermissionResult.denied,
        PermissionStatus.permanentlyDenied => PermissionResult.permanentlyDenied,
        PermissionStatus.restricted => PermissionResult.restricted,
        _ => PermissionResult.denied,
      };
}
