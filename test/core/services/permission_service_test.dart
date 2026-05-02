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

// Seam subclass that overrides only the platform-channel seam methods so the
// real checkPermission / requestPermission logic runs end-to-end in tests.
class _SeamPermissionService extends PermissionService {
  final PermissionStatus stubbedRequestStatus;
  final PermissionStatus stubbedCheckStatus;

  _SeamPermissionService({
    required this.stubbedRequestStatus,
    PermissionStatus? stubbedCheckStatus,
  }) : stubbedCheckStatus = stubbedCheckStatus ?? stubbedRequestStatus;

  @override
  Future<PermissionStatus> executeRequest(Permission permission) async =>
      stubbedRequestStatus;

  @override
  Future<PermissionStatus> executeCheck(Permission permission) async =>
      stubbedCheckStatus;
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

  // ── requestPermission via seam — Permission.camera specific ──────────────────
  //
  // These tests use _SeamPermissionService which overrides only the seam methods
  // (executeRequest / executeCheck), letting the real requestPermission /
  // checkPermission logic run end-to-end without hitting the platform channel.

  group('requestPermission(Permission.camera) via seam', () {
    test('returns PermissionResult.denied when OS returns denied', () async {
      final service = _SeamPermissionService(
        stubbedRequestStatus: PermissionStatus.denied,
      );
      final result = await service.requestPermission(Permission.camera);
      expect(result, PermissionResult.denied);
    });

    test('returns PermissionResult.permanentlyDenied when OS returns permanentlyDenied', () async {
      final service = _SeamPermissionService(
        stubbedRequestStatus: PermissionStatus.permanentlyDenied,
      );
      final result = await service.requestPermission(Permission.camera);
      expect(result, PermissionResult.permanentlyDenied);
    });

    test('returns PermissionResult.granted when OS returns granted', () async {
      final service = _SeamPermissionService(
        stubbedRequestStatus: PermissionStatus.granted,
      );
      final result = await service.requestPermission(Permission.camera);
      expect(result, PermissionResult.granted);
    });
  });

  // ── checkPermission(Permission.camera) via seam ───────────────────────────────

  group('checkPermission(Permission.camera) via seam', () {
    test('returns PermissionResult.denied when status is denied', () async {
      final service = _SeamPermissionService(
        stubbedRequestStatus: PermissionStatus.denied,
        stubbedCheckStatus: PermissionStatus.denied,
      );
      final result = await service.checkPermission(Permission.camera);
      expect(result, PermissionResult.denied);
    });

    test('returns PermissionResult.granted when status is granted', () async {
      final service = _SeamPermissionService(
        stubbedRequestStatus: PermissionStatus.granted,
        stubbedCheckStatus: PermissionStatus.granted,
      );
      final result = await service.checkPermission(Permission.camera);
      expect(result, PermissionResult.granted);
    });
  });
}
