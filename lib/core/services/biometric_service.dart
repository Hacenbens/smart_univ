import 'package:local_auth/local_auth.dart';

class BiometricService {
  final _auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    if (!await _auth.isDeviceSupported()) return false;
    if (!await _auth.canCheckBiometrics) return false;
    final available = await _auth.getAvailableBiometrics();
    return available.isNotEmpty;
  }

  Future<bool> authenticate() => _auth.authenticate(
        localizedReason: 'Confirm your identity to sign in',
      );
}
