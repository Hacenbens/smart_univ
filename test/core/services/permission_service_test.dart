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
  bool openSettingsCalled = false;

  // Controls what openSettings() returns in tests.
  bool openSettingsResult = true;
  // When true, openSettings() throws instead of returning normally.
  bool openSettingsThrows = false;

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

  @override
  Future<bool> openSettings() async {
    openSettingsCalled = true;
    if (openSettingsThrows) throw Exception('OEM intent not handled');
    return openSettingsResult;
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

  // ── openSettings ─────────────────────────────────────────────────────────────

  group('openSettings', () {
    test('returns true when the OS settings page opens successfully', () async {
      final fake = _FakePermissionService(PermissionStatus.permanentlyDenied)
        ..openSettingsResult = true;

      final result = await fake.openSettings();

      expect(result, isTrue);
      expect(fake.openSettingsCalled, isTrue);
    });

    test('returns false when the OS returns false (settings unavailable)', () async {
      final fake = _FakePermissionService(PermissionStatus.permanentlyDenied)
        ..openSettingsResult = false;

      final result = await fake.openSettings();

      expect(result, isFalse);
    });

    test('returns false instead of throwing on OEM skins that throw', () async {
      // Simulates MIUI / One UI behaviour where the settings intent throws.
      final fake = _FakePermissionService(PermissionStatus.permanentlyDenied)
        ..openSettingsThrows = true;

      final result = await fake.openSettings();

      expect(result, isFalse);
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
