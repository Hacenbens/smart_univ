import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_univ/core/services/permission_service.dart';

void main() {
  // PermissionService.mapStatus() is @visibleForTesting so we call it directly,
  // avoiding any platform-channel calls from permission.request() / .status.
  late PermissionService service;

  setUp(() => service = PermissionService());

  group('PermissionService.mapStatus', () {
    test('granted → PermissionResult.granted', () {
      expect(service.mapStatus(PermissionStatus.granted), PermissionResult.granted);
    });

    test('limited (partial iOS access) → PermissionResult.granted', () {
      // iOS photo library "limited" selection is treated as usable — callers
      // should not receive denied when some access exists.
      expect(service.mapStatus(PermissionStatus.limited), PermissionResult.granted);
    });

    test('denied → PermissionResult.denied', () {
      expect(service.mapStatus(PermissionStatus.denied), PermissionResult.denied);
    });

    test('permanentlyDenied → PermissionResult.permanentlyDenied', () {
      expect(
        service.mapStatus(PermissionStatus.permanentlyDenied),
        PermissionResult.permanentlyDenied,
      );
    });

    test('restricted → PermissionResult.restricted', () {
      expect(
        service.mapStatus(PermissionStatus.restricted),
        PermissionResult.restricted,
      );
    });
  });

  group('PermissionResult enum', () {
    test('contains exactly the four expected variants', () {
      expect(PermissionResult.values, [
        PermissionResult.granted,
        PermissionResult.denied,
        PermissionResult.permanentlyDenied,
        PermissionResult.restricted,
      ]);
    });
  });
}
