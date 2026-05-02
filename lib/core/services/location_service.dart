import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/core/services/permission_service.dart';

class LocationService {
  LocationService(this._permissionService);

  final PermissionService _permissionService;

  Future<bool> isLocationServiceEnabled() => executeServiceCheck();

  Future<Position> getCurrentPosition() async {
    final result = await _permissionService.requestPermission(
      Permission.locationWhenInUse,
    );
    if (result != PermissionResult.granted) {
      throw const PermissionException('Location permission denied');
    }
    return executeGetPosition(
      const LocationSettings(accuracy: LocationAccuracy.medium),
    );
  }

  Stream<Position> getPositionStream() => executeGetStream(
        const LocationSettings(accuracy: LocationAccuracy.medium),
      );

  // ── Platform-call seams (overridable in tests) ──────────────────────────────

  @visibleForTesting
  Future<bool> executeServiceCheck() => Geolocator.isLocationServiceEnabled();

  @visibleForTesting
  Future<Position> executeGetPosition(LocationSettings settings) =>
      Geolocator.getCurrentPosition(locationSettings: settings);

  @visibleForTesting
  Stream<Position> executeGetStream(LocationSettings settings) =>
      Geolocator.getPositionStream(locationSettings: settings);
}
