import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_univ/core/services/permission_service.dart';

// Subclass that overrides the platform-channel calls so tests run without
// a device. Each method records whether it was invoked, letting tests assert
// that check and request are strictly independent paths.
class _FakePermissionService extends PermissionService {
  final PermissionStatus stubbedStatus;

  bool checkCalled = false;
  bool requestCalled = false;

  _FakePermissionService(this.stubbedStatus);

  @override
  Future<PermissionResult> checkPermission(Permission permission) async {
    checkCalled = true;
    return mapStatus(stubbedStatus);
  }

  @override
  Future<PermissionResult> requestPermission(Permission permission) async {
    requestCalled = true;
    return mapStatus(stubbedStatus);
  }
}

void main() {
  // ── mapStatus (pure mapping, no platform channels) ───────────────────────────

  group('PermissionService.mapStatus', () {
    late PermissionService service;
    setUp(() => service = PermissionService());

    test('granted → PermissionResult.granted', () {
      expect(service.mapStatus(PermissionStatus.granted), PermissionResult.granted);
    });

    test('limited (partial iOS access) → PermissionResult.granted', () {
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

  // ── checkPermission — silent status read, no dialog ──────────────────────────

  group('checkPermission', () {
    test('returns correct result for each status without triggering request', () async {
      for (final entry in {
        PermissionStatus.granted: PermissionResult.granted,
        PermissionStatus.limited: PermissionResult.granted,
        PermissionStatus.denied: PermissionResult.denied,
        PermissionStatus.permanentlyDenied: PermissionResult.permanentlyDenied,
        PermissionStatus.restricted: PermissionResult.restricted,
      }.entries) {
        final fake = _FakePermissionService(entry.key);
        final result = await fake.checkPermission(Permission.camera);

        expect(result, entry.value,
            reason: '${entry.key} should map to ${entry.value}');
        expect(fake.checkCalled, isTrue,
            reason: 'checkPermission path must be taken');
        expect(fake.requestCalled, isFalse,
            reason: 'checkPermission must never call requestPermission');
      }
    });
  });

  // ── requestPermission — triggers system dialog ────────────────────────────────

  group('requestPermission', () {
    test('returns correct result and does not touch checkPermission path',
        () async {
      final fake = _FakePermissionService(PermissionStatus.granted);
      final result = await fake.requestPermission(Permission.camera);

      expect(result, PermissionResult.granted);
      expect(fake.requestCalled, isTrue);
      expect(fake.checkCalled, isFalse,
          reason: 'requestPermission must not silently check instead of request');
    });
  });

  // ── PermissionResult enum completeness ───────────────────────────────────────

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
