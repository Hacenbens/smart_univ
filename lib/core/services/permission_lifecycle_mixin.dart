import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_univ/core/services/permission_service.dart';

/// Adds lifecycle-aware permission re-checking to a [State].
///
/// When the user returns from the OS settings page (after tapping **Open Settings**
/// in [PermissionService.showPermanentlyDeniedDialog]), the app resumes and
/// [didChangeAppLifecycleState] automatically re-calls [checkPermission], so
/// the UI updates without any manual tap.
///
/// Usage:
/// ```dart
/// class _MyScreenState extends State<MyScreen>
///     with WidgetsBindingObserver, PermissionLifecycleMixin<MyScreen> {
///
///   @override
///   Permission get observedPermission => Permission.camera;
///
///   @override
///   PermissionService get permissionService => getIt<PermissionService>();
///
///   @override
///   void onPermissionStatusChanged(PermissionResult result) {
///     setState(() { _permissionResult = result; });
///   }
/// }
/// ```
mixin PermissionLifecycleMixin<T extends StatefulWidget>
    on State<T>, WidgetsBindingObserver {
  /// The permission to re-check on every app resume.
  Permission get observedPermission;

  /// The service used to check the permission.
  PermissionService get permissionService;

  /// Called with the fresh [PermissionResult] each time the app resumes.
  void onPermissionStatusChanged(PermissionResult result);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      permissionService
          .checkPermission(observedPermission)
          .then(onPermissionStatusChanged);
    }
  }
}
