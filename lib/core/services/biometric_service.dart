import 'dart:io';

import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Whether the device has biometric hardware and at least one enrolled credential.
  Future<bool> isAvailable() async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final supported = await _auth.isDeviceSupported();
      return canCheck || supported;
    } catch (_) {
      return false;
    }
  }

  /// Shows the system biometric / device-credential prompt.
  /// Returns true only on a successful match; returns false on cancel or error.
  Future<bool> authenticate() async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    try {
      return await _auth.authenticate(
        localizedReason: 'Verify your identity to access SmartCampus',
        options: const AuthenticationOptions(
          biometricOnly: false, // allow PIN / pattern fallback
          stickyAuth: true,     // keep prompt alive if app loses focus
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
