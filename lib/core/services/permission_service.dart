import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_univ/core/widgets/rationale_dialog.dart';

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
/// ```dart
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
    final status = await executeCheck(permission);
    return mapStatus(status);
  }

  /// Shows the system permission dialog for [permission] and returns the
  /// user's decision. Only call this in response to an explicit user gesture
  /// (button tap, menu action, etc.) — never at app or screen startup.
  Future<PermissionResult> requestPermission(Permission permission) async {
    final status = await executeRequest(permission);
    return mapStatus(status);
  }

  /// Deep-links the user to the OS app settings page so they can manually
  /// toggle a permission that was [PermissionResult.permanentlyDenied] or
  /// [PermissionResult.restricted].
  ///
  /// Returns `true` if the settings page was opened successfully.
  /// Returns `false` on failure — some Android OEM skins (MIUI, One UI) do
  /// not handle the intent correctly and throw instead of returning false.
  Future<bool> openSettings() async {
    try {
      return await openAppSettings();
    } catch (_) {
      return false;
    }
  }

  /// Shows a pre-rationale dialog explaining WHY [feature] permission is needed,
  /// before the OS dialog fires.
  ///
  /// Returns `true` if the user taps **Continue** (caller should then call
  /// [requestPermission]), or `false` if they tap **Not Now**.
  ///
  /// Per Android guidelines, only show this when
  /// `shouldShowRequestPermissionRationale()` returns true (i.e. the user
  /// has denied the permission once before without "never ask again").
  Future<bool> showRationaleDialog(BuildContext context, String feature) async {
    bool result = false;
    await showDialog<void>(
      context: context,
      builder: (ctx) => RationaleDialog(
        title: 'Permission Required',
        body: 'SmartCampus needs $feature access to attach photos to your event notes.',
        allowLabel: 'Continue',
        denyLabel: 'Not Now',
        onAllow: () {
          result = true;
          Navigator.of(ctx).pop();
        },
        onDeny: () => Navigator.of(ctx).pop(),
      ),
    );
    return result;
  }

  /// Shows a dialog informing the user that [feature] permission was permanently
  /// denied, and directing them to the OS settings to re-enable it.
  ///
  /// **Open Settings** calls [openSettings] and dismisses the dialog.
  /// The caller must use [PermissionLifecycleMixin] to re-check the permission
  /// when the user returns from settings.
  Future<void> showPermanentlyDeniedDialog(
    BuildContext context,
    String feature,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => RationaleDialog(
        title: '$feature Access Blocked',
        body: '$feature access was permanently denied. '
            'Enable it in Settings to use this feature.',
        allowLabel: 'Open Settings',
        denyLabel: 'Cancel',
        onAllow: () {
          Navigator.of(ctx).pop();
          openSettings();
        },
        onDeny: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  // ── Platform-call seams (overridable in tests) ──────────────────────────────

  /// Calls [permission.request()] — triggers the system dialog.
  /// Override in tests to avoid hitting the platform channel.
  @visibleForTesting
  Future<PermissionStatus> executeRequest(Permission permission) =>
      permission.request();

  /// Reads [permission.status] — no dialog shown.
  /// Override in tests to avoid hitting the platform channel.
  @visibleForTesting
  Future<PermissionStatus> executeCheck(Permission permission) =>
      permission.status;

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
